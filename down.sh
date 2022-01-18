#!/bin/bash

remaining_pods() {
    kubectl get pods -n spinnaker -l app.kubernetes.io/part-of=spinnaker -o json | jq -r '.items | length'
}

kubectl delete spinnakerservice spinnaker -n spinnaker

remaining=$(remaining_pods)
while [ ${remaining} -gt 0 ]; do
    echo "=== remaining pods: ${remaining}"
    sleep 5s
    remaining=$(remaining_pods)
done

kubectl delete -f ./initial-setup.yaml

if [ -d ./tmp/deploy ]; then
    kubectl delete -f ./tmp/deploy/crds/
    kubectl -n spinnaker-operator delete -f ./tmp/deploy/operator/cluster
fi
