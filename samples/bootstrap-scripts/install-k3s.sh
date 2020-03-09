#!/bin/bash

# Install options
# https://rancher.com/docs/k3s/latest/en/installation/install-options/

curl -sfL https://get.k3s.io | sh -

# Ensure kubectl/k3s are useable by buildkite user
mkdir -p /etc/rancher/k3s
touch /etc/rancher/k3s/k3s.yaml
chown -Rh buildkite:buildkite /etc/rancher/k3s

setup_kubectl() {
  k3s kubectl get nodes
}
export -f setup_kubectl
su buildkite -c "bash -c setup_kubectl"
