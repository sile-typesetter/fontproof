PACKAGE = fontproof

SHELL := bash
.SHELLFLAGS := -e -c

.ONESHELL:
.SECONDEXPANSION:
.DELETE_ON_ERROR:
.SUFFIXES:

VERSION != git describe --tags --always --abbrev=7 | sed 's/-/-r/'
SEMVER != git describe --tags | sed 's/^v//;s/-.*//'
ROCKREV = 1
TAG ?= v$(SEMVER)

LUAROCKS_ARGS ?= --local --tree lua_modules

DEV_SPEC = $(PACKAGE)-dev-$(ROCKREV).rockspec
DEV_ROCK = $(PACKAGE)-dev-$(ROCKREV).src.rock
REL_SPEC = rockspecs/$(PACKAGE)-$(SEMVER)-$(ROCKREV).rockspec
REL_ROCK = $(PACKAGE)-$(SEMVER)-$(ROCKREV).src.rock

.PHONY: all
all: rockspecs dist

.PHONY: rockspecs
rockspecs: $(DEV_SPEC) $(REL_SPEC)

.PHONY: dist
dist: $(DEV_ROCK) $(REL_ROCK)

.PHONY: install
install: $(DEV_SPEC)
	luarocks $(LUAROCKS_ARGS) make $(DEV_SPEC)

define rockspec_template =
	sed -e "s/@PACKAGE@/$(PACKAGE)/g" \
		-e "s/@SEMVER@/$(SEMVER)/g" \
		-e "s/@ROCKREV@/$(ROCKREV)/g" \
		-e "s/@TAG@/$(TAG)/g" \
		$< > $@
endef

$(DEV_SPEC): SEMVER = dev
$(DEV_SPEC): TAG = master
$(DEV_SPEC): $(PACKAGE).rockspec.in
	$(rockspec_template)
	sed -i \
		-e "1i -- DO NOT EDIT! Modify template $< and rebuild with \`make $@\`" \
		-e '/tag =/s/tag/branch/' \
		$@

rockspecs/$(PACKAGE)-%-$(ROCKREV).rockspec: SEMVER = $*
rockspecs/$(PACKAGE)-%-$(ROCKREV).rockspec: TAG = v$*
rockspecs/$(PACKAGE)-%-$(ROCKREV).rockspec: $(PACKAGE).rockspec.in
	$(rockspec_template)
	sed -i \
		-e '/rockspec_format/s/3.0/1.0/' \
		-e '/url = "git/a\   dir = "$(PACKAGE)",' \
		-e '/issues_url/d' \
		-e '/maintainer/d' \
		-e '/labels/d' \
		$@

$(DEV_ROCK): $(DEV_SPEC)
	luarocks $(LUAROCKS_ARGS) pack $<

$(PACKAGE)-%.src.rock: rockspecs/$(PACKAGE)-%.rockspec
	luarocks $(LUAROCKS_ARGS) pack $<

_BRANCH_REF != $(AWK) '{print ".git/" $$2}' .git/HEAD 2>/dev/null ||:

.version: $(_BRANCH_REF)
	[[ -e "$@" ]] && mv "$@" "$@-prev" || touch "$@-prev"
	printf "$(VERSION)" > "$@"

export DOCKER_REGISTRY ?= ghcr.io
export DOCKER_REPO ?= sile-typesetter/$(PACKAGE)
export DOCKER_TAG ?= HEAD

.PHONY: docker
docker: Dockerfile hooks/build .version
	./hooks/build $(VERSION)

.PHONY: docker-build-push
docker-build-push: docker
	docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	test -z "$(DOCKER_PAT)" || \
		docker login https://$(DOCKER_REGISTRY) -u $(DOCKER_USERNAME) -p $(DOCKER_PAT)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	if [[ "$(DOCKER_TAG)" == v*.*.* ]]; then \
		tag=$(DOCKER_TAG) ; \
		docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ; \
		docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ; \
		docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ; \
		docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ; \
	fi

$(MAKEFILE_LIST):;
