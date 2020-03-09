#!/bin/sh

# This script is the StackScript for Linode

exec >/var/log/stackscript.log 2>&1

set -eux -o pipefail

# <UDF name="buildkite_token" Label="Buildkite account token" />
# <UDF name="buildkite_spawn" Label="The number of agents to spawn in parallel" default="5" />
# <UDF name="buildkite_bootstrap_script_url" Label="Run external script to customize Linode during boot." default="" />
# <UDF name="buildkite_secrets_bucket" Label="AWS S3 bucket containing secrets" default="" />
# <UDF name="aws_access_key" Label="AWS access key for S3 buckets" default="" />
# <UDF name="aws_secret_password" Label="AWS access secret key for S3 buckets" default="" />

LINODE_STACK=${LINODE_STACK:-633367}
BUILDKITE_QUEUE=${BUILDKITE_QUEUE:-default}

# explicit aws installation to support alpine
install_aws() {
  apk add openssh-client groff less -uUv --force-overwrite
  apk --update add --virtual .build-dependencies python3-dev libffi-dev openssl-dev build-base
  pip3 install --no-cache --upgrade \
    requests \
    awscli \
    awsebcli \
    boto3 \
    cfn-flip \
    cfn-lint \
    PyYAML \
    sceptre

  mkdir ~buildkite/.aws
  cat > ~buildkite/.aws/config <<CONFIG
[default]
region = us-east-1
CONFIG

  cat > ~buildkite/.aws/credentials <<CREDS
[default]
aws_access_key_id = ${AWS_ACCESS_KEY}
aws_secret_access_key = ${AWS_SECRET_PASSWORD}
CREDS

  chown -Rh buildkite:buildkite ~buildkite/.aws
  chmod 700 ~buildkite/.aws
  chmod 600 ~buildkite/.aws/*
}

install_s3_plugin() {
  S3_SECRETS_DIR=~buildkite/.buildkite-agent/plugins/elastic-ci-stack-s3-secrets-hooks

  git clone \
    https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks \
    $S3_SECRETS_DIR

  cat > ~buildkite/.buildkite-agent/hooks/environment <<SHELL
export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET="$BUILDKITE_SECRETS_BUCKET"

source $S3_SECRETS_DIR/hooks/environment
SHELL
}

apk add curl docker bash git ca-certificates

rc-update add docker boot
service docker start

# Create buildkite user/group
addgroup -g 100000 buildkite
adduser -G buildkite -u 100000 -D buildkite
addgroup buildkite docker

TOKEN="$BUILDKITE_TOKEN" bash -c "`curl -sL https://raw.githubusercontent.com/buildkite/agent/master/install.sh`"

BUILDKITE_DIR=/home/buildkite/.buildkite-agent
mv /root/.buildkite-agent $BUILDKITE_DIR

DOCKER_VERSION=$(docker --version | cut -f3 -d' ' | sed 's/,//')

export BUILDKITE_AGENT_NAME="linode-$LINODE_ID-dc-$LINODE_DATACENTERID"
sed -i "s/name=.*$/name=\"$BUILDKITE_AGENT_NAME\"/g" $BUILDKITE_DIR/buildkite-agent.cfg
cat <<CFG >> $BUILDKITE_DIR/buildkite-agent.cfg
spawn="$BUILDKITE_SPAWN"
tags=queue=${BUILDKITE_QUEUE},docker=${DOCKER_VERSION},linode-stack=${LINODE_STACK},linode-id=${LINODE_ID},linode-ram=${LINODE_RAM},linode-dc-id=${LINODE_DATACENTERID}
tags-from-host=true
CFG

[[ -n "${BUILDKITE_SECRETS_BUCKET:-}" && -n "${AWS_ACCESS_KEY:-}" &&  -n "${AWS_SECRET_PASSWORD:-}" ]] && {
  echo "--> Setup AWS S3 buckets"
  install_aws

  echo "--> Install S3 plugin"
  install_s3_plugin
}

[[ -n "${BUILDKITE_BOOTSTRAP_SCRIPT_URL:-}" ]] && {
  echo "--> Running bootstrap script"
  curl -sSL "${BUILDKITE_BOOTSTRAP_SCRIPT_URL}" \
    -o $BUILDKITE_DIR/bootstrap-script.sh
  chmod +x $BUILDKITE_DIR/bootstrap-script.sh
  $BUILDKITE_DIR/bootstrap-script.sh
}

chown -Rh buildkite:buildkite $BUILDKITE_DIR

curl -L https://raw.githubusercontent.com/starkandwayne/buildkite-cloudfoundry-demo-app/master/ci/agent/buildkite-agent.openrc.sh > /etc/init.d/buildkite-agent
chmod +x /etc/init.d/buildkite-agent
rc-update add buildkite-agent
service buildkite-agent start