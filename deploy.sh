#!/usr/bin/env bash

function ExitOnError(){
    local -ir ErrorStatus="$1" ExitVal="$3"
    local -r ErrorMessage="$2"

    if [ $ErrorStatus -ne 0 ]; then
        echo "$ErrorMessage";
        exit "$ExitVal";
    fi
}

function TestService() {
    local -r service="$1"
    local -r port=$( \
        kubectl get service "$service" \
            --output='jsonpath={.spec.ports[0].nodePort}' \
    )

    nc -z $(minikube ip) "$port" -w 3
}

function DeployService(){
    local -r DeployStateMessage="$1" ConfigFile="$2" service="$3"
    local -r ServiceTestMessage="$4" ErrorMessage="$5" Deployment="$7"
    local -ir ExitVal="$6"

    echo "$DeployStateMessage"
    kubectl apply --filename configuration/"$ConfigFile".yml &&
        kubectl rollout status deployment/"$Deployment"

    echo "$ServiceTestMessage"
    TestService "$service"
    
    ExitOnError $? "$ErrorMessage" "$ExitVal"
}

# Secrets
echo "Adding Secrets"
kubectl apply --filename configuration/.secret.yml &&
    kubectl get secret db-user-env-variables > /dev/null 2>&1

ExitOnError $? "Issue Registering Secrets" 1

# Init Script
echo "Regstering MariaDB Init Script with ConfigMap"
kubectl create configmap db-init-script --from-file=db/init.sql \
    --output=yaml --dry-run=client | kubectl apply --filename -

# Volume
echo "Adding MariaDB Persistence Volume and Claim"
kubectl apply --filename configuration/db-persistence.yml &&
    kubectl get persistentvolumes db-volume > /dev/null 2>&1

ExitOnError $? "Couldnt Create DB Persistent Volume" 7

kubectl apply --filename configuration/db-persistence-claim.yml &&
    kubectl get persistentvolumeclaims db-volume-claim > /dev/null 2>&1

ExitOnError $? "Couldnt Create DB Persistent Volume Claim" 8

# Services: MariaDB PHPMyAdmin Express API
Params=(
    "'Deploying && Exposing mariadb' mariadb mariadb-service 'Testing MariaDB Service' 'Issue Deploying MariaDB' 2 mariadb-deployment" # MariaDB
    "'Deploying && Exposing DB interface (PHPMyAdmin)' php-my-admin pma-service 'Testing PHPMyAdmin Service' \
        'Issue Deploying Database Interface (PHPMyAdmin)' 3 phpmyadmin-deployment"
    "'Deploying && Exposing API' api api-service 'Testing Express API Service' 'Issue Deploying API' 4 api-deployment"
)

for param in "${Params[@]}"; do
    eval DeployService "$param"
done

echo "Deployed!"