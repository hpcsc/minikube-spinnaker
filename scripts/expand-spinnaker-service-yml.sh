#!/bin/bash

set -euo pipefail

KUBE_CONFIG=$(./scripts/export-kube-config.sh)
MINIKUBE_IP=$(minikube ip)
DECK_NODEPORT=32070
GATE_NODEPORT=32064

function replace_profile() {
    local profile_name=$1
    if [ -f "./profiles/${profile_name}.yml" ]; then
        yq eval-all "select(fileIndex==0).spec.spinnakerConfig.profiles.${profile_name} = select(fileIndex==1) | select(fileIndex==0)" \
            ./spinnakerservice.yaml \
            "./profiles/${profile_name}.yml"
    else
        cat ./spinnakerservice.yaml
    fi
}

replace_profile orca | \
    yq eval ".spec.spinnakerConfig.config.artifacts.gitrepo.accounts[0].token = env(GITHUB_TOKEN) | \
                        .spec.spinnakerConfig.files.local-kubernetes = \"${KUBE_CONFIG}\" | \
                        .spec.spinnakerConfig.service-settings.deck.overrideBaseUrl = \"http://${MINIKUBE_IP}:${DECK_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.deck.env.API_HOST = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.gate.overrideBaseUrl = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\"" -
