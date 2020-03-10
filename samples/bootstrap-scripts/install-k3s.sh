#!/bin/bash

BUILDKITE_DIR=${BUILDKITE_DIR:-/home/buildkite/.buildkite-agent}
sed -i "s/tags=/ s/$/k3s-role=master/" $BUILDKITE_DIR/buildkite-agent.cfg

# Install options
# https://rancher.com/docs/k3s/latest/en/installation/install-options/

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh
chmod +x /tmp/install-k3s.sh
export INSTALL_K3S_SKIP_START=true
/tmp/install-k3s.sh || { echo "Failed for the moment"; }

service k3s start

# Ensure kubectl/k3s are useable by buildkite user
mkdir -p /etc/rancher/k3s
chown -Rh buildkite:buildkite /etc/rancher/k3s

setup_kubectl() {
  k3s kubectl get nodes
}
export -f setup_kubectl
su buildkite -c "bash -c setup_kubectl"

