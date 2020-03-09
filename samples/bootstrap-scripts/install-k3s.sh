#!/bin/bash

# Install options
# https://rancher.com/docs/k3s/latest/en/installation/install-options/

curl -sfL https://get.k3s.io | sh -

chown -Rh buildkite:buildkite /etc/rancher/k3s

k3s kubectl get nodes
