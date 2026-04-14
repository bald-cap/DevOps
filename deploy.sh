#!/usr/bin/env bash

set -x
. .env

# Logging in to Docker
docker login --username "$DOCKERHUB_USERNAME" --password "$DOCKERHUB_PASSWORD"

function IsReady(){
    local -r service="$1"
    pod_names=$(kubectl get pods --selector="app=$service" --output='jsonpath={.items[*].metadata.name}') && \
    read -ra pods <<< "$pod_names" # Casting to Array

    for pod in "$pods"; do
        kubectl wait \
            --for='jsonpath={.status.phase}'=Running \
            pod/"$pod" ;
    done
}

function TestService() {
    local -r service="$1"
    local -r deployment="$2"
    local -r port=$(kubectl get services/"$service" --output='go-template={{(index .spec.ports 0).port}}') # Complete

#    kubectl port-forward service/"$service" 8080:"$port" &
    nc -zv 127.0.0.1 "$port"

    ErrorStatus=$?
    if [ $ErrorStatus -ne 0 ]; then
        echo "Service in Active";
        exit 6;
    fi
}

# Adding Secrets
kubectl apply --filename configuration/.secret.yml &&
    kubectl get secret db-user-env-variables > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Issue Registering Secrets"
    exit 1
fi

# Deploying mariadb and Opening its Service
kubectl apply --filename configuration/mariadb.yml &&
    IsReady mariadb

# TODO:  Expose Service and curl --silent the Service to see what it returns
TestService mariadb-service mariadb-deployment

if [ $? -ne 0 ]; then
    echo "Issue Deploying MariaDB"
    exit 2
fi

# Deploying DB interface (PHPMyAdmin) and Opening its service
kubectl apply --filename configuration/php-my-admin.yml &&
    IsReady db-interface

# TODO:  Expose Service and curl --silent the Service to see what it returns
TestService pma-service phpmyadmin-deployment

if [ $? -ne 0 ]; then
    echo "Issue Deploying Database Interface (PHPMyAdmin)"
    exit 3
fi

echo "Deployed!"
