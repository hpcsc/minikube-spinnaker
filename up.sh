#!/bin/bash

set -euo pipefail

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "environment variable GITHUB_TOKEN is required"
    exit 1
fi

CONTEXT=${1:-minikube}

mkdir -p ./tmp
curl -L https://github.com/armory/spinnaker-operator/releases/latest/download/manifests.tgz | tar -xz -C ./tmp

echo "=== setup namespaces, install minio"
kubectl apply --context=${CONTEXT} -f ./initial-setup.yaml

echo "=== install spinnaker operator"
kubectl apply --context=${CONTEXT} -f ./tmp/deploy/crds/
kubectl apply --context=${CONTEXT} -n spinnaker-operator -f ./tmp/deploy/operator/cluster

echo "=== wait for minio and operator to be ready."
kubectl wait --context=${CONTEXT} --for=condition=Available deployment --all -n spinnaker --timeout=5m
kubectl wait --context=${CONTEXT} --for=condition=Available deployment --all -n spinnaker-operator --timeout=15m

echo "=== create SpinnakerService"
./scripts/expand-spinnaker-service-yml.sh | kubectl --context=${CONTEXT} apply -f -

while [ "$(kubectl get spinnakerservice spinnaker --context=${CONTEXT} -n spinnaker -o json | jq -r '.status.serviceCount // 0')" == "0" ]; do
    echo "=== operator has not picked up SpinnakerService CR yet"
    sleep 1s
done

echo "=== deployments created from SpinnakerService, wait for deployments to be ready"
kubectl wait --context=${CONTEXT} --for=condition=Available deployment --all -n spinnaker --timeout=15m
