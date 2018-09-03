centos:
	docker build -f Dockerfile        -t perconalab/pmm-client:centos --no-cache --squash .

alpine:
	docker build -f Dockerfile-alpine -t perconalab/pmm-client:alpine --no-cache --squash .
