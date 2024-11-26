set ignore-comments := true
set shell := ["zsh", "+o", "nomatch", "-ecu"]
set unstable := true
set script-interpreter := ["zsh", "+o", "nomatch", "-eu"]

_default:
	@just --list --unsorted

[private]
[doc('Block execution if Git working tree isn’t pristine.')]
pristine:
	# Ensure there are no changes in staging
	git diff-index --quiet --cached HEAD || exit 1
	# Ensure there are no changes in the working tree
	git diff-files --quiet || exit 1

[private]
[doc('Block execution if we don’t have access to private keys.')]
keys:
	gpg -a --sign > /dev/null <<< "test"

release semver: pristine
	sed -i -e "/image:/s/:v.*/:v{{semver}}/" action.yml
	make rockspecs/fontproof-{{semver}}-1.rockspec
	git add action.yml README.md rockspecs/fontproof-{{semver}}-1.rockspec
	git commit -m "chore: Release {{semver}}"
	git tag v{{semver}}
	git push --atomic upstream master v{{semver}}
	luarocks pack rockspecs/fontproof-{{semver}}-1.rockspec
	gh release create v{{semver}} -t "FontProof v{{semver}}" fontproof-{{semver}}-1.src.rock

post-release semver: keys
	gh release download --clobber v{{semver}}
	ls fontproof-{{semver}}-1.src.rock | xargs -n1 gpg -a --detach-sign
	gh release upload v{{semver}} fontproof-{{semver}}-1.src.rock.asc

# vim: set ft=just
