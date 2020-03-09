LINODE_CLI=linode-cli
STACKSCRIPT_ID=633367

view:
	linode-cli stackscripts view $(STACKSCRIPT_ID)

update:
	$(LINODE_CLI) stackscripts update $(STACKSCRIPT_ID) \
		--script "`cat ./linode-stackscript.sh`"
