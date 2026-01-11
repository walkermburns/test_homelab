Created roughly following the guide from https://github.com/TechHutTV/homelab with custom modifications to not be so extra.
There is also the guide https://trash-guides.info/ with some other information
# Setting Up Gluetun
Gluetun setup instructions [here](https://github.com/qdm12/gluetun?tab=readme-ov-file#setup)

[Private Internet Access instructions](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md)

[Golang application to generate wireguard configuration for PIA](https://github.com/kylegrantlucas/pia-wg-config) (much faster than OpenVPN) 

`pia-wg-config -o wg0.conf -r us_alabama-pf USERNAME PASSWORD`
> You must run this on the machine that will use the configuration!

The PIA configuration for Gluetun does not support wireguard, so you have to use a [custom configuration](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md#wireguard)

Good way to check that the VPN is working and isolating the network is to run in another terminal:

`docker run --rm --network=container:gluetun alpine:3.18 sh -c "apk add wget && wget -qO- https://ipinfo.io"`

## Port forwarding (may not be needed for tailscale network)

Port forwarding is enabled by the `VPN_PORT_FORWARDING=on` option in the .env file for the gluetun container. This is supported by PIA, but only on OpenVPN as of right now. 

in order to know which port is being forwarded, [you must run a command](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#native-integrations):
`VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "echo My forwarded ports are {{PORTS}}, the first forwarded port is {{PORT}} and the VPN network interface is {{VPN_INTERFACE}}"`

This command will run when the VPN comes up, and it can be used to send API commands to torrenting software as detailed in the linked docs.

> Port forwarding is only required for remote access of the media server applications through the VPN IP or for certain seeding configurations. Not needed if you don't need to seed. (still not sure of the requirements or penalties for seeding) Tailscale basically makes this irrelevant

# Setting up *arr apps

All of the *arr applications (Raddarr, Sonarr, Prowlarr) have similar interfaces and setups.

Prowlarr is a helpful but optional application that consolidates some of the configurations for the other apps, most namely the index list. When connected to the other apps it will synchronize the list whenever it is updated.

Radarr and Sonarr are sister applications for movies and tv shows respectively, the indexes are synced from prowlarr. Each has their own quality settings. When searching, a list of movies is returned from the index, and the application will prioritize downloads of the bitrate specified

## Network configuration problems

The typical setup for these applications is to have prowlarr exposed to the VPN network as it will search indexes directly, and the other *arr apps will be on a local network. I was not able to get this working, I could not authenticate the other applicaitons in prowlarr when prowlarr was connected to the gluetun container network, but the other apps were only on the securenet subnet. This should be acheivable with some more tinkering, the same as a home network connecting its internet connection to the local subnet. But this is dangerous as securenet is by default not behind the vpn and pings back as my home IP.

Additionally, as the Plex container is configured separately, it does not have access to securenet and raddarr/sonarr cannot automatically refresh the library upon new updates.

## flaresolverr - additional app for prowlarr
Some indicies will have cloudflare captchas or ddos protection, and will require flaresolverr to be installed. The setup for this container is fairly simple. The default settings worked fine for me. All I had to do was add it under the index proxy settings in prowlarr, tag it as "flaresolverr" and tag any of the indexes that require it with the same.

# Setting up Deluge Download Client

Deluge is pretty easily added to each of the *arrs individually, it just connects to the default port with a password. You will need to add the tagging plugin to allow each app to tag its own downloads. You can also download anything and use the app tag to make it sort it itself (although you may need to add the title in the app after downloading to make it monitor the download progress). For each tag, you will need to manually edit and add a "move when complete" folder location for movies and tv respectively.

The most important thing here is to have a good folder structure. The torrent download location and the media location need to have the same top-level directory (/data in this case). the *arr apps will read the download location from deluge and try to access it, this means that they will need to see the same top level directory. However, if you don't want your torrent application to be able to see the media directory, you will have to attach it to the container as such: `- /media/4tb/data/torrents:/data/torrents` This only imports the torrents directory, but mounts it in the container under the subdirectory /data/ so that radarr and sonarr will read it as "/data/torrents/ and will know the location to go and link the media from.

## Note on usenet

Usenet is apparently a better way to get media. However, it requires subscribing to a number of services, you need both indexers and a download provider that are typically a few dollars a month. It requires different download clients.