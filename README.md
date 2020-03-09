# Linode StackScripts for Buildkite Agents

Provision Buildkite Agents on Linodes using the following Linode StackScript:

* [drnic/buildkite-agent-alpine](https://cloud.linode.com/stackscripts/633367) for Alpine 3.11

This repository contains the Linode StackScript, and additional scripts and config files, to provision [Buildkite Agents](https://buildkite.com/agent) on Linodes.

## Find StackScripts

Using the `linode-cli`:

```plain
$ make view
┌────────┬──────────┬────────────────────────┬───────────────────┬───────────┬─────────────────────┬─────────────────────┐
│ id     │ username │ label                  │ images            │ is_public │ created             │ updated             │
├────────┼──────────┼────────────────────────┼───────────────────┼───────────┼─────────────────────┼─────────────────────┤
│ 633367 │ drnic    │ buildkite-agent-alpine │ linode/alpine3.11 │ True      │ 2020-02-19T18:41:47 │ 2020-03-04T02:47:23 │
└────────┴──────────┴────────────────────────┴───────────────────┴───────────┴─────────────────────┴─────────────────────┘
```

## Provision Sample Linodes

Requirements:

```plain
export BUILDKITE_TOKEN=...
export LINODE_ROOT_PASSWORD=...
```

Provision Linode with 5 Buildkite Agents and Docker Daemon

```plain
make linode-create
```

Provision Linode with K3s, 5 Buildkite Agents and Docker Daemon

```plain
export BOOTSTRAP_SCRIPT_URL=https://raw.githubusercontent.com/starkandwayne/buildkite-linode-stackscript/master/samples/bootstrap-scripts/install-k3s.sh

make linode-create
```
