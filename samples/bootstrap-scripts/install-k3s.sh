#!/bin/bash

# Install options
# https://rancher.com/docs/k3s/latest/en/installation/install-options/

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh
sh < /tmp/install-k3s.sh

# Ensure kubectl/k3s are useable by buildkite user
chown -Rh buildkite:buildkite /etc/rancher/k3s

setup_kubectl() {
  k3s kubectl get nodes
}
export -f setup_kubectl
su buildkite -c "bash -c setup_kubectl"
