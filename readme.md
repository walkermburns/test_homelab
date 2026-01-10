Created roughly following the guide from https://github.com/TechHutTV/homelab with custom modifications to not be so extra.
# Setting Up Gluetun
Gluetun setup instructions [here](https://github.com/qdm12/gluetun?tab=readme-ov-file#setup)

[Private Internet Access instructions](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md)

[Golang application to generate wireguard configuration for PIA](https://github.com/kylegrantlucas/pia-wg-config) (much faster than OpenVPN) 

`pia-wg-config -o wg0.conf -r us_alabama-pf USERNAME PASSWORD`
>NOTE: You must run this on the machine that will use the configuration!

The PIA configuration for Gluetun does not support wireguard, so you have to use a [custom configuration](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md#wireguard)

Good way to check that the VPN is working and isolating the network is to run in another terminal: `docker run --rm --network=container:gluetun alpine:3.18 sh -c "apk add wget && wget -qO- https://ipinfo.io"`