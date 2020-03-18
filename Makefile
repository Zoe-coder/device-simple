.PHONY: build test clean prepare update docker

GO=CGO_ENABLED=0 GO111MODULE=on go

MICROSERVICES=cmd/device-simple
.PHONY: $(MICROSERVICES)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 0.0.0)

GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-simple.Version=$(VERSION)"

GIT_SHA=$(shell git rev-parse HEAD)

build: $(MICROSERVICES)
	$(GO) build ./...

cmd/device-simple:
	$(GO) build $(GOFLAGS) -o $@ ./cmd

docker:
	docker build \
		-f example/cmd/device-simple/Dockerfile \
		--label "git_sha=$(GIT_SHA)" \
		-t edgexfoundry/docker-device-sdk-simple:$(GIT_SHA) \
		-t edgexfoundry/docker-device-sdk-simple:$(VERSION)-dev \
		.

test:
	$(GO) test ./... -coverprofile=coverage.out 
	$(GO) vet ./...
	gofmt -l .
	[ "`gofmt -l .`" = "" ]
	./bin/test-attribution-txt.sh
	./bin/test-go-mod-tidy.sh

clean:
	rm -f $(MICROSERVICES)
