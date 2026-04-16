#!/usr/bin/env bash

kubectl delete --filename configuration/ --ignore-not-found

kubectl delete configmap db-init-script --ignore-not-found