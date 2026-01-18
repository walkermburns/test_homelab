docker compose up

# required for plex to recognize local server
# make sure to have plex container subnet forwarded in tailscale
# for some reason this is not configurable in compose.yaml
docker network connect bridge plex 