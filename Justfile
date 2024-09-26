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

release semver: pristine
	sed -i -e "/image:/s/:v.*/:v{{semver}}/" action.yml
	make rockspecs/fontproof-{{semver}}-1.rockspec
	git add action.yml README.md rockspecs/fontproof-{{semver}}-1.rockspec
	git commit -m "chore: Release {{semver}}"
	git tag v{{semver}}
	git push upstream v{{semver}}
	git push upstream master
	luarocks pack rockspecs/fontproof-{{semver}}-1.rockspec
	gh release create v{{semver}} -t "FontProof v{{semver}}" fontproof-{{semver}}-1.src.rock

# vim: set ft=just
