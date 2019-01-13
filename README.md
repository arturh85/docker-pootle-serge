Pootle+Serge Docker Container
=======================

Fork of https://github.com/1drop/pootle with an updated version of Pootle and integrated Serge based on https://github.com/evernote/serge-dockerfiles.

- [Pootle](https://pootle.translatehouse.org/) is a Community localization server - Get your community translating your software into their languages.  
- [Serge](https://serge.io/) is a Free, Open-Source Solution for Continuous Localization

## Environment Variables:

    POOTLE_CANONICAL_URL=http://pootle.docker
    POOTLE_TITLE=TYPO3 Translation Server
    POOTLE_ADMIN_NAME=John Doe
    POOTLE_ADMIN_MAIL=john.doe@mail.com
    POOTLE_SENDER_MAIL=no-reply@pootle.docker
    SECRET_KEY=4JY+9C9kEWASJk5MVkYH8ynd5ka9aRq56jssTwa2key8CZrSipNi1vD/1lPfzcqx/UY=
    
    MYSQL_HOST=mysql
    MYSQL_USER=pootle
    MYSQL_PASSWORD=ChangeMe
    MYSQL_DATABASE=pootle
    MYSQL_PORT=3306
    
    REDIS_HOST=redis
    REDIS_PORT=6379
    
## Volumes (for serge, optional):

    -v /var/serge:/var/serge
    -v /var/serge/lib:/usr/lib/serge/vendor/lib:ro

## Initialize MySQL DB on first Start

    docker run -it --rm -e MYSQL_HOST "mysql" -e MYSQL_DATABASE "pootle" -e MYSQL_USER "pootle" -e MYSQL_PASSWORD "ChangeMe" arturh85/pootle-serge bash
    
then inside the bash:

    pootle migrate
    pootle initdb
    pootle createsuperuser
    pootle verify_user --all

## Example Usage:

    docker run -d --name pootle-serge -p 5394:8000 -e REDIS_HOST "redis" -e MYSQL_HOST "mysql" -e MYSQL_DATABASE "pootle" -e MYSQL_USER "pootle" -e MYSQL_PASSWORD "ChangeMe" -e SECRET_KEY "changeMe" -e POOTLE_TITLE "My Pootle Translation Server" -v /var/serge:/var/serge -v /var/serge/lib:/usr/lib/serge/vendor/lib:ro --restart=always arturh85/pootle-serge
