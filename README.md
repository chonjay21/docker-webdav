# [**WebDav**](https://github.com/chonjay21/docker-webdav)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/chonjay21/webdav)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/chonjay21/webdav)
![Docker Pulls](https://img.shields.io/docker/pulls/chonjay21/webdav)
![GitHub](https://img.shields.io/github/license/chonjay21/docker-webdav)
![Docker Stars](https://img.shields.io/docker/stars/chonjay21/webdav?style=social)
![GitHub stars](https://img.shields.io/github/stars/chonjay21/docker-webdav?style=social)
## WebDav based on official latest httpd image
* Support Authentication (BasicAuth|DigestAuth)
* Support SSL(https) with automatically generated self signed certificate
* Support URL prefix for reverse proxy
* Support umask change
* Support UserID|GroupID change
* Support custom TimeZone
* Support custom event script override

<br />

# Who I am
Our goal is to create a simple, consistent, customizable and convenient image using official image

Find me at:
* [GitHub](https://github.com/chonjay21)
* [Blog](https://chonjay.tistory.com/)

<br />

# Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64, latest |
| armhf | arm32v7, latest |

<br />

# Usage

Here are some example snippets to help you get started running a container.

## docker (simple)

```
docker run -e APP_USER_NAME=admin -e APP_USER_PASSWD=admin -e APP_UID=1000 -e APP_GID=1000 -p 80:80 -p 443:443 -v /webdav/data:/var/webdav/data chonjay21/webdav
```

## docker

```
docker run \
  -e APP_USER_NAME=admin	\
  -e APP_USER_PASSWD=admin	\
  -e APP_UID=1000	\
  -e APP_GID=1000	\
  -e APP_UMASK=007                                                `#optional`	\
  -e TZ=America/Los_Angeles                                       `#optional` \
  -e USE_SSL=true                                                 `#optional`	\
  -e FORCE_REINIT_CONFIG=false                                    `#optional` \
  -e SERVER_NAME=WebDav.example.org                               `#optional` \
  -e DIGEST_AUTH_REALM=WebDav                                     `#optional` \
  -e URL_PREFIX=/webdav                                           `#optional` \
  -p 80:80 \
  -p 443:443 \
  -v /webdav/data:/var/webdav/data \
  -v /webdav/config:/webdav/config                                `#optional for persistent data` \
  -v /webdav/server.key:/usr/local/apache2/conf/server.key:ro     `#optional for ssl` \
  -v /webdav/server.crt:/usr/local/apache2/conf/server.crt:ro     `#optional for ssl` \
  chonjay21/webdav
```


## docker-compose

Compatible with docker-compose v2 schemas. (also compatible with docker-compose v3)

```
version: '2.2'
services:
  webdav:
    container_name: webdav
    image: "chonjay21/webdav:latest"
    ports:
      - 80:80
      - 443:443
    environment:
      - APP_USER_NAME=admin
      - APP_USER_PASSWD=admin
      - APP_UID=1000
      - APP_GID=1000
      - APP_UMASK=007                                                 #optional
      - TZ=America/Los_Angeles                                        #optional
      - USE_SSL=true                                                  #optional
      - FORCE_REINIT_CONFIG=false                                     #optional
      - SERVER_NAME=WebDav.example.org                                #optional
      - DIGEST_AUTH_REALM=WebDav                                      #optional
      - URL_PREFIX=/webdav                                            #optional
    volumes:
      - /webdav/data:/var/webdav/data
      - /webdav/config:/webdav/config                                 #optional
      - /webdav/server.key:/usr/local/apache2/conf/server.key:ro      #optional
      - /webdav/server.crt:/usr/local/apache2/conf/server.crt:ro      #optional
```

# Parameters

| Parameter | Function | Optional |
| :---- | --- | :---: |
| `-p 80` | for http port |  |
| `-p 443` | for https port |  |
| `-e APP_USER_NAME=admin` | for login username (basic auth) |  |
| `-e APP_USER_PASSWD=admin` | for login password (basic auth) |  |
| `-e APP_UID=1000` | for filesystem permission (userid)  |  |
| `-e APP_GID=1000` | for filesystem permission (groupid)  |  |
| `-e APP_UMASK=007` | for filesystem file permission umask (default 007)  | O |
| `-e TZ=America/Los_Angeles` | for timezone  | O |
| `-e USE_SSL=true` | for ssl encryption(https) with automatically created self signed certificate  | O |
| `-e FORCE_REINIT_CONFIG=false` | if true, always reinitialize APP_USER_NAME etc ...  | O |
| `-e SERVER_NAME=WebDav.example.org` | for apache servername field  | O |
| `-e DIGEST_AUTH_REALM=WebDav` | for use DigestAuth(Default BasicAuth)  | O |
| `-e URL_PREFIX=/webdav` | for subpath behind reverse proxy  | O |
| `-v /var/webdav/data` | for data access with this container |
| `-v /webdav/config` | for persistent data | O |
| `-v /usr/local/apache2/conf/server.key` | for custom ssl certificate | O |
| `-v /usr/local/apache2/conf/server.crt` | for custom ssl certificate | O |

<br />

# Event scripts

All of our images are support custom event scripts

| Script | Function |
| :---- | --- |
| `/sources/webdav/eventscripts/on_pre_init.sh` | called before initialize container (only for first time) |
| `/sources/webdav/eventscripts/on_post_init.sh` | called after initialize container (only for first time) |
| `/sources/webdav/eventscripts/on_run.sh` | called before running app (every time) |

You can override these scripts for custom logic
for example, if you don`t want your password exposed by environment variable, you can override on_pre_init.sh in this manner

## Exmaple - on_pre_init.sh
```
#!/usr/bin/env bash
set -e

APP_USER_PASSWD=mysecretpassword    # or you can set password from secret store and get with curl etc ...
```

## 1. Override with volume mount
```
docker run \
  ...
  -v /webdav/on_pre_init.sh:/sources/webdav/eventscripts/on_pre_init.sh \
  ...
  chonjay21/webdav
```

## 2. Override with Dockerfile
```
FROM chonjay21/webdav:latest
ADD host/on_pre_init.sh /sources/webdav/
```

<br />

# License

View [license information](https://github.com/chonjay21/docker-webdav/blob/master/LICENSE) of this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

## License of httpd official image

View [license information](https://www.apache.org/licenses/) of official httpd license