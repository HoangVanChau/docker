#! /bin/bash
docker-compose up php81 php82 nginx mariadb postgres minio mailhog -d
docker compose exec -u root -it php${1:-81} bash
