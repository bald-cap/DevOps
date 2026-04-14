#!usr/bin/env sh

. .env

# Logging in to Docker
docker login --username "$DOCKERHUB_USERNAME" --password "$DOCKERHUB_PASSWORD"

function IsReady(){
    local -r podname="$1"
    kubectl wait \
        --for='jsonpath={.status.phase}'=Running \
        pod/"$podname"
}

function TestService() {
    local -r service="$1"
    local -r deployment="$2"
    local -r port=$(kubectl get services/"$service" --output='go-template={{(index .spec.ports 0).nodePort}}') # Complete

    kubectl port-forward service/"$service" "$port":8080 &

    curl --silent --insecure https://127.0.0.1:8080

    if [ $? -ne 0 ]; then
        echo "Issue Registering Secrets"
        return 1
    else
        return 0
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
TestService  mariadb-service mariadb-deployment

if [ $? -ne 0 ]; then
    echo "Issue Deploying MariaDB"
    exit 2
fi

# Deploying DB interface (PHPMyAdmin) and Opening its service
kubectl apply --filename php-my-admin.yml &&
    IsReady db-interface

# TODO:  Expose Service and curl --silent the Service to see what it returns
TestService  phpmyadmin-service phpmyadmin-deployment

if [ $? -ne 0 ]; then
    echo "Issue Deploying Database Interface (PHPMyAdmin)"
    exit 3
fi

echo "Deployed!"
