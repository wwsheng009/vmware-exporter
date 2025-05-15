# Makefile

BINARY_NAME=vmware-exporter
DOCKER_IMAGE=vmware-exporter:latest

.PHONY: all build clean run docker

all: build

build:
	GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOAMD64=v2 go build -a -ldflags '-extldflags "-static"' -o $(BINARY_NAME) vmware-exporter.go

clean:
	rm -f $(BINARY_NAME)

run: build
	./$(BINARY_NAME)

docker:
	docker build -t $(DOCKER_IMAGE) .
