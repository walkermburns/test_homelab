Created roughly following the guide from https://github.com/TechHutTV/homelab with custom modifications to not be so extra.
# Setting Up Gluetun
Gluetun setup instructions [here](https://github.com/qdm12/gluetun?tab=readme-ov-file#setup)

[Private Internet Access instructions](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md)

[Golang application to generate wireguard configuration for PIA](https://github.com/kylegrantlucas/pia-wg-config) (much faster than OpenVPN) 

`pia-wg-config -o wg0.conf -r us_alabama-pf USERNAME PASSWORD`
> [!TIP] You must run this on the machine that will use the configuration!

The PIA configuration for Gluetun does not support wireguard, so you have to use a [custom configuration](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md#wireguard)

Good way to check that the VPN is working and isolating the network is to run in another terminal:

`docker run --rm --network=container:gluetun alpine:3.18 sh -c "apk add wget && wget -qO- https://ipinfo.io"`

## Port forwarding (may not be needed for tailscale network)

Port forwarding is enabled by the `VPN_PORT_FORWARDING=on` option in the .env file for the gluetun container. This is supported by PIA, but only on OpenVPN as of right now. 

in order to know which port is being forwarded, [you must run a command](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#native-integrations):
`VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "echo My forwarded ports are {{PORTS}}, the first forwarded port is {{PORT}} and the VPN network interface is {{VPN_INTERFACE}}"`

This command will run when the VPN comes up, and it can be used to send API commands to torrenting software as detailed in the linked docs.