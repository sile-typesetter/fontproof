VERSION := $(shell git describe --long --tags --always)

_BRANCH_REF := $(shell $(AWK) '{print ".git/" $$2}' .git/HEAD 2>/dev/null ||:)

.version: $(_BRANCH_REF)
	[ -e "$@" ] && mv "$@" "$@-prev" || touch "$@-prev"
	printf "$(VERSION)" > "$@"

export DOCKER_REGISTRY ?= ghcr.io
export DOCKER_REPO ?= sile-typesetter/fontproof
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
