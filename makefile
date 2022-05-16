
# this file assumes you're already in a nix-shell

.PHONY: build clean

build:
	# TODO: generate it
	agda -i. Everything.agda

clean:
	-find . -name '*.agdai' -exec rm -rfv '{}' \;
