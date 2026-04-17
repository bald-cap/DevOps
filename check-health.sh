#!/usr/bin/env bash

function CheckService(){
    local -ir ErrorStatus="$1"
    local -r ErrorMessage="$2"

    if [ $ErrorStatus -ne 0 ]; then
        echo "$ErrorMessage";
        pods_string=$(kubectl get pods \
            --output='jsonpath={.item[*].metadata.name}' \
            --field-selector=status.phase!=Running \
        )
        
        read -ra pods <<< "$pods_string"
        for pod in "${pods[@]}"; do
            kubectl logs "$pod" --tail=20
        done
    fi
}

ports_string=$( \
    kubectl get services \
        --output='jsonpath={.items[?(@.metadata.name!="kubernetes")].spec.ports[0].nodePort}' \
)

read -ra ports <<< "$ports_string" # Casting String to Array

status=0
KubeIp=$(minikube ip)
for port in "${ports[@]}"; do
    echo "Checking service on port $port..."  

    nc -z "$KubeIp" "$port" -w 3

    if test $? -ne 0; then
        status=1
        break
    fi
done

CheckService "$status" "Service Not Reachable" 