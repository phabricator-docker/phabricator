# phabricator
Unofficial Base Docker Image for Phabricator

Updated by [phabricator/bot](https://hub.docker.com/r/phabricator/bot/) every
hour, on the hour.

## arm devices
Phabricator itself can run on any LAMP server stack. Technically MySQL and MariaDB (which is used in this setup) are available for _arm64_ and _armhf_ but Docker Hub is missing such images.
The workaround that can be used is to use the _linuxserver/mariadb_ image which is an unofficial image built from the official source of MariaDB and compatibile with `arm64 arm64v8-latest` and `armhf arm32v7-latest`.

In `docker-compose.yml` simply change the source image to `linuxserver/mariadb` and the persistance volume to `/config` to respect the new image folder tree:

```
database:
    image: linuxserver/mariadb
    volumes:
       - db-data:/config
```

### Configuring the new database
* Once the deploy is completed run `docker ps -a` to check the ip of the container which holds the database and note it down.
* Get into the phabricator container with ` docker exec -it <container_id> bash`
  * `cd phabricator`
  * `./bin/config set mysql.host "ip_of_the_database_container"`
  * `./bin/config set mysql.port "3306"`
  * `./bin/config set mysql.pass "password_chosen_in_docker-compose.yml"`
