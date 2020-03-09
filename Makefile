LINODE_CLI=linode-cli
STACKSCRIPT_ID=633367

view:
	linode-cli stackscripts view $(STACKSCRIPT_ID)

update:
	$(LINODE_CLI) stackscripts update $(STACKSCRIPT_ID) \
		--script "`cat ./linode-stackscript.sh`"

open:
	open "https://cloud.linode.com/linodes/create?type=One-Click&subtype=Community%20StackScripts&stackScriptID=$(STACKSCRIPT_ID)"
