# etherpad-sqlite-docker

Docker image for etherpad-lite with the sqlite dependency installed.
For documentation, see [ether/etherpad-lite](https://github.com/ether/etherpad-lite).


## Links

- [etherpad-sqlite on dockerhub](https://hub.docker.com/r/tiimb/etherpad-sqlite)
- [etherpad github](https://github.com/ether/etherpad-lite)
- [etherpad on dockerhub](https://hub.docker.com/r/tiimb/etherpad/etherpad)

## Example usage


```yml
# docker-compose.yml
version: '3.7'
services:
  etherpad:
    image: tiimb/etherpad-sqlite
    restart: unless-stopped
    ports:
      - 9001:9001
    volumes:
      - ~/docker/etherpad:/opt/etherpad-lite/var/db
    environment:
      - DB_TYPE=sqlite
      - DB_FILENAME=var/db/db.sqlite
```

```bash
# create folder for the database
mkdir -p ~/docker/etherpad
chmod 777 ~/docker/etherpad

docker-compose up
```