#!/usr/bin/env bash

. .env

tag=${1:-latest}

docker build --tag "$DOCKERHUB_USERNAME"/acme-api:"$tag" api/

docker login --username "$DOCKERHUB_USERNAME" --password "$DOCKERHUB_PASSWORD"

docker push baldcap/acme-api:"$tag"