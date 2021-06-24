# vars
BASH=bash

install-linode:
	$(BASH) scripts/install-linode.bash $(host)
