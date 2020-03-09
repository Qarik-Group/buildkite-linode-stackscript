LINODE_CLI=linode-cli
STACKSCRIPT_ID=633367

view:
	linode-cli stackscripts view $(STACKSCRIPT_ID)

update:
	$(LINODE_CLI) stackscripts update $(STACKSCRIPT_ID) \
		--script "`cat ./linode-stackscript.sh`"

open:
	open "https://cloud.linode.com/linodes/create?type=One-Click&subtype=Community%20StackScripts&stackScriptID=$(STACKSCRIPT_ID)"

linodes-create :
	$(LINODE_CLI) linodes create \
		--stackscript_id $(STACKSCRIPT_ID) \
		--stackscript_data '{"buildkite_token": "${BUILDKITE_TOKEN}", "buildkite_spawn": "5", "buildkite_bootstrap_script_url": "${BOOTSTRAP_SCRIPT_URL}", "buildkite_secrets_bucket": "${BUILDKITE_SECRETS_BUCKET}", "aws_access_key": "${AWS_ACCESS_KEY}", "aws_secret_password": "${AWS_SECRET_KEY}"}' \
		--region ap-west \
		--type g6-standard-2 \
		--image linode/alpine3.11 \
		--root_pass "${LINODE_ROOT_PASSWORD}" \
		--tags buildkite-agent \
		--label buildkite-agent-1

linode-create : linodes-create

linodes-delete :
	$(LINODE_CLI) linodes list --tags buildkite-agent --json | jq -r ".[].id" | xargs -L1 linode-cli linodes delete

linode-delete : linodes-delete

linodes-list :
	$(LINODE_CLI) linodes list --tags buildkite-agent

linode-list : linodes-list

.PHONY : view update open \
	linode-create linodes-create \
	linode-list linodes-list \
	linode-delete linodes-delete
