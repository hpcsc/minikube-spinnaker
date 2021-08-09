#!/bin/bash

set -euo pipefail

KUBE_CONFIG=$(./export-kube-config.sh)
MINIKUBE_IP=$(minikube ip)
DECK_NODEPORT=32070
GATE_NODEPORT=32064

cat ./spinnakerservice.yaml | \
    yq eval ".spec.spinnakerConfig.config.artifacts.gitrepo.accounts[0].token = env(GITHUB_TOKEN) | \
                        .spec.spinnakerConfig.files.local-kubernetes = \"${KUBE_CONFIG}\" | \
                        .spec.spinnakerConfig.service-settings.deck.overrideBaseUrl = \"http://${MINIKUBE_IP}:${DECK_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.deck.env.API_HOST = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\" | \
                        .spec.spinnakerConfig.service-settings.gate.overrideBaseUrl = \"http://${MINIKUBE_IP}:${GATE_NODEPORT}\"" -
