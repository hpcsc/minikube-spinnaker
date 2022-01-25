#!/bin/bash

CONTEXT=${1:-minikube}

remaining_pods() {
    kubectl get pods --context=${CONTEXT} -n spinnaker -l app.kubernetes.io/part-of=spinnaker -o json | jq -r '.items | length'
}

kubectl delete spinnakerservice spinnaker -n spinnaker --context=${CONTEXT}

remaining=$(remaining_pods)
while [ ${remaining} -gt 0 ]; do
    echo "=== remaining pods: ${remaining}"
    sleep 5s
    remaining=$(remaining_pods)
done

kubectl delete --context=${CONTEXT} -f ./initial-setup.yaml

if [ -d ./tmp/deploy ]; then
    kubectl delete --context=${CONTEXT} -f ./tmp/deploy/crds/
    kubectl delete --context=${CONTEXT} -n spinnaker-operator -f ./tmp/deploy/operator/cluster
fi
