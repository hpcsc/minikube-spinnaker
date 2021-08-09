#!/bin/bash

set -euo pipefail

function get_escaped_yaml() {
    local file_path=$1
    if [ -f "${file_path}" ]; then
        echo "\"$(sed 's/\"/\\"/g' "${file_path}")\""
    else
        echo "{}"
    fi
}

KUBE_CONFIG=$(./export-kube-config.sh)
MINIKUBE_IP=$(minikube ip)
DECK_NODEPORT=32070
GATE_NODEPORT=32064
ORCA_PROFILE="$(get_escaped_yaml ./profiles/orca.yml)"

cat ./spinnakerservice.yaml | \
    yq eval ".spec.spinnakerConfig.config.artifacts.gitrepo.accounts[0].token = env(GITHUB_TOKEN) | \
                        .spec.spinnakerConfig.files.local-kubernetes = \"${KUBE_CONFIG}\" | \
                        .spec.spinnakerConfig.profiles.orca = ${ORCA_PROFILE} | \
                        .spec.spinnakerConfig.service-settings.deck.overrideBaseUrl = \"http://${MINIKUBE_IP}:${DECK_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.deck.env.API_HOST = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.gate.overrideBaseUrl = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\"" -
