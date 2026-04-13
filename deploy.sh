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

# Adding Secrets
kubectl apply --filename .secret.yml &&
    kubectl get secret db-user-env-variables > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Issue Registering Secrets"
    exit 1
fi

# Deploying mariadb and Opening its Service
kubectl apply --filename mariadb.yml &&
    IsReady mariadb

if [ $? -ne 0 ]; then
    echo "Issue Deploying MariaDB"
    exit 2
fi

# Deploying DB interface (PHPMyAdmin) and Opening its service
kubectl apply --filename php-my-admin.yml &&
    IsReady db-interface

if [ $? -ne 0 ]; then
    echo "Issue Deploying Database Interface (PHPMyAdmin)"
    exit 3
fi

echo "Deployed!"