#!usr/bin/sh env
. .env

docker login --username "$DOCKERHUB_USERNAME" --password "$DOCKERHUB_PASSWORD"