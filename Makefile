ORG                     := automatethethingsllc
TARGET_OS               := linux
TARGET_ARCH             := $(shell uname -m)

CORES                   ?= $(shell nproc)
ARCH                    := $(shell go env GOARCH)
OS                      := $(shell go env GOOS)
BUILDDIR                := $(shell pwd)
TIMESTAMP               := $(shell date +"%Y-%m-%d_%H-%M-%S")
NUMPROC                 := $(shell nproc)
BROWSER                 ?= /usr/bin/firefox
#LOCAL_ADDRESS           ?= $(shell hostname -I | cut -d " " -f1)
LOCAL_ADDRESS           ?= localhost

GOBIN                   := $(shell dirname `which go`)

APP                     := cropdroid
APPTYPE					?= standalone

ENV             		?= dev
TARGET_USER             ?= pi
TARGET_HOST             ?= 192.168.0.131
GITHUB_TOKEN            ?= 9022f875bfb2876dfdf1e925ea70e7a73963bffd

HOSTNAME                ?= cropdroid1
ETH0_CIDR               ?= 192.168.0.131/24
ETH0_ROUTERS            ?= 192.168.1.1
ETH0_DNS                ?= 192.168.1.1
WLAN_CIDR               ?= 192.168.100.131/24
WLAN_ROUTERS            ?= 192.168.100.1
WLAN_DNS                ?= 192.168.100.1
WLAN_SSID               ?= MJ_5G
WLAN_PSK                ?= Westland1
WLAN_KEY_MGMT           ?= WPA-PSK
WLAN_COUNTRY            ?= US

DEVOPS_HOME             ?= devops
FIRMWARE_HOME           ?= $(HOME)/eclipse-workspace
FIRMWARE_STAGE          ?= hardware/firmware
BOOTLOADER_STAGE        ?= hardware/bootloaders
IMAGES_HOME             ?= $(DEVOPS_HOME)/images
DEPLOY_HOME             ?= /opt/$(APP)

SOURCES                 ?= $(HOME)/sources
RPI_KERNEL=             ?= $(SOURCES)/qemu-rpi-kernel
IMAGE_NAME				?= $(HOSTNAME)-$(APPTYPE)-$(ENV)
#RPI_BASE_IMAGE          ?= 2020-05-27-raspios-buster-arm64
RPI_BASE_IMAGE			?= output-raspios-$(APPTYPE)-$(ENV)
RPI_IMAGE_ARTIFACT      ?= $(IMAGES_HOME)/$(IMAGE_NAME).img
RPI_SDCARD              ?= /dev/sda

SCRIPTS                 ?= $(DEVOPS_HOME)/scripts

PACKER_FILE             ?= raspios64-2021-05-07-dev.json

WEBSERVER_USER          ?= www-data

CROPDROID_VERSION       ?= $(shell git describe --tags --abbrev=0)
GIT_TAG=$(shell git describe --tags)
GIT_HASH=$(shell git rev-parse HEAD)
BUILD_DATE=$(shell date '+%y-%m-%d_%H:%M:%S')

LDFLAGS=-X github.com/jeremyhahn/$(APP)/app.Image=${IMAGE_NAME}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.Environment=${ENV}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.Release=${CROPDROID_VERSION}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.GitHash=${GIT_HASH}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.GitTag=${GIT_TAG}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.BuildUser=${USER}
LDFLAGS+= -X github.com/jeremyhahn/$(APP)/app.BuildDate=${BUILD_DATE}

# Required by Ansible playbook and Packer AMI build
AWS_ACCESS_KEY_ID      ?=
AWS_SECRET_ACCESS_KEY  ?=
AWS_REGION             ?= us-east-1
AWS_PROFILE            ?= default

# Cookbook global variables
HOSTED_ZONE            ?= $(APP).com
HOSTED_ZONE_ID		   ?=
ADMIN_EMAIL            ?= hostmaster@$(HOSTED_ZONE)
COMMON_NAME            ?= $(APP)-$(ENV).$(HOSTED_ZONE)

# Required by docker / jenkins targets
DOCKER_HOME              ?= $(DEVOPS_HOME)/docker
DOCKER_LOCAL_REGISTRY    ?= $(LOCAL_ADDRESS):5000
DOCKER_REGISTRY_DNS		 ?= registry.cropdroid.local
DOCKER_REGISTRY          ?= docker.io
DOCKER_USERNAME          ?= jeremyhahn
DOCKER_PASSWORD          ?= 
DOCKER_EMAIL             ?= mail@jeremyhahn.com
DOCKER_SUBNET            ?= 172.17.0.0/16
DOCKER_NODE1_IP          ?= 172.17.0.10
DOCKER_NODE2_IP          ?= 172.17.0.11
DOCKER_NODE3_IP          ?= 172.17.0.12
DOCKER_OS                ?= ubuntu
DOCKER_OS_TAG		     ?= latest
DOCKER_IMAGE             ?= $(DOCKER_OS):$(DOCKER_OS_TAG)
DOCKER_ALPINE_IMAGE      ?= alpine:latest
DOCKER_GOLANG_IMAGE      ?= golang:buster

DOCKER_BUILDER_ROCKSDB_BASE_IMAGE ?= ubuntu:20.10
DOCKER_BUILDER_ROCKSDB_VERSION    ?= 6.10.fb

DOCKER_BUILDER_COCKROACH_BASE_IMAGE ?= golang:latest
DOCKER_BUILDER_COCKROACH_VERSION    ?= v21.1.1

ifdef DOCKER_LOCAL
	DOCKER_ENDPOINT ?= $(DOCKER_LOCAL_REGISTRY)/
else
	DOCKER_ENDPOINT ?= $(DOCKER_REGISTRY)/$(DOCKER_USERNAME)/
	#DOCKER_ENDPOINT ?= $(DOCKER_USERNAME)/
endif

ifeq ($(MINIKUBE_LOCAL),1)
	DOCKER_ENDPOINT=
endif

#JENKINS_PLUGINS        := $(shell cat $(DEVOPS_HOME)/jenkins/plugins.txt | tr '\n' ' ')
#JENKINS_IMAGE          ?= $(/$(APP)-jenkins

.PHONY: deps build build-deps build-amd64 build-arm build-arm-ssh \
	 clean unittest integrationtest ssh install install-amd64 install-arm \
	 virtual server cloud

#default: clean build unittest integrationtest deploy initdb server
default: build-arm



docker-info:
	@echo $(MINIKUBE_INSTALL)
	@echo $(MINIKUBE_LOCAL)
	@echo $(DOCKER_ENDPOINT)



certs:
	mkdir -p keys/
	openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout keys/key.pem -out keys/cert.pem \
          -subj "/C=US/ST=MA/L=Boston/O=Automate The Things, LLC/CN=localhost"
	openssl genrsa -out keys/rsa.key 2048
	openssl rsa -in keys/rsa.key -pubout -out keys/rsa.pub



room1:
	ENV=prod $(MAKE) build-arm packer-raspios sdimage

room2:
	ENV=prod HOSTNAME=cropdroid2 ETH0_CIDR=192.168.0.132/24 WLAN_CIDR=192.168.100.132/24 $(MAKE) build-arm packer-raspios sdimage



# ------------- #
# Git #
# ------------- #
init:
	mkdir src
	git clone git@github.com:jeremyhahn/cropdroid-devops.git devops
	git clone git@github.com:jeremyhahn/go-cropdroid.git src/
	git clone git@github.com:jeremyhahn/cropdroid-room.git src/
	git clone git@github.com:jeremyhahn/cropdroid-reservoir.git src/
	git clone git@github.com:jeremyhahn/cropdroid-doser.git src/



# ------------- #
# Docker Images #
# ------------- #
docker-build-base:
	docker build \
	  --build-arg BASE_IMAGE=$(DOCKER_GOLANG_IMAGE) \
	  -t $(DOCKER_ENDPOINT)builder-cropdroid-base-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-base/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-base-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-rocksdb:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=$(DOCKER_BUILDER_ROCKSDB_BASE_IMAGE) \
	  --build-arg ROCKSDB_VERSION=$(DOCKER_BUILDER_ROCKSDB_VERSION) \
	  -t $(DOCKER_ENDPOINT)builder-rocksdb-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-rocksdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-rocksdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cockroachdb:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=$(DOCKER_BUILDER_COCKROACH_BASE_IMAGE) \
	  --build-arg COCKROACH_VERSION=$(DOCKER_BUILDER_COCKROACH_VERSION) \
	  -t $(DOCKER_ENDPOINT)builder-cockroachdb-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cockroachdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cockroachdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-standalone:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  -t $(DOCKER_ENDPOINT)builder-cropdroid-standalone-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-standalone .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-standalone-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-cluster:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  --build-arg ROCKSDB_IMAGE=builder-rocksdb-$(DOCKER_OS) \
	  -t $(DOCKER_ENDPOINT)builder-cropdroid-cluster-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-cluster-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-cluster-from-source:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  --build-arg ROCKSDB_IMAGE=builder-rocksdb-$(DOCKER_OS) \
	  -t $(DOCKER_ENDPOINT)builder-cropdroid-cluster-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster-from-source .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-cluster-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-standalone:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg STANDALONE_BUILDER=builder-cropdroid-standalone-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-standalone-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-standalone-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-standalone-alpine:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg STANDALONE_BUILDER=builder-cropdroid-standalone-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-standalone-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-alpine .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-standalone-alpine $(MAKE) docker-local
endif

docker-build-cropdroid-cluster-alpine:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=builder-rocksdb-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-cluster-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-alpine .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-alpine $(MAKE) docker-local
endif

docker-build-cropdroid-cluster:
	docker build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=builder-rocksdb-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-cluster-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cockroachdb:
	docker build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg COCKROACHDB_BUILDER=builder-cockroachdb-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cockroachdb-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cockroachdb-$(DOCKER_OS) $(MAKE) docker-local
endif

# Cockroach builds arent done static so they fail in alpine
# docker-build-cockroachdb-alpine:
# 	docker build \
# 		--build-arg CORES=$(CORES) \
# 		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
# 		--build-arg COCKROACHDB_BUILDER=builder-cockroachdb-$(DOCKER_OS) \
# 		-t $(DOCKER_ENDPOINT)cockroachdb-alpine \
# 		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-alpine .
# ifdef DOCKER_PUSH
# 	DOCKER_IMAGE=cockroachdb-alpine $(MAKE) docker-local
#endif

docker-build-builders: docker-build-builder-rocksdb \
	docker-build-builder-cockroachdb \
	docker-build-builder-cropdroid-standalone \
	docker-build-builder-cropdroid-cluster

docker-build-cropdroid: docker-build-cropdroid-standalone \
    docker-build-cropdroid-cluster

docker-build-cropdroid-alpine: docker-build-cropdroid-standalone-alpine \
	docker-build-cropdroid-cluster-alpine

docker-build-all: docker-build-base \
	docker-build-builders \
	docker-build-cockroachdb \
	docker-build-cropdroid \
	docker-build-cropdroid-alpine


docker-buildx-create:
	docker buildx create --name mybuilder
	docker buildx use mybuilder
	docker buildx inspect --bootstrap

docker-buildx-base:
	docker buildx build \
	    --build-arg BASE_IMAGE=$(DOCKER_GOLANG_IMAGE) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-base/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)builder-cropdroid-base-$(DOCKER_OS) .

docker-buildx-rocksdb:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_BUILDER_ROCKSDB_BASE_IMAGE) \
	  	--build-arg ROCKSDB_VERSION=$(DOCKER_BUILDER_ROCKSDB_VERSION) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-rocksdb/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)builder-rocksdb-$(DOCKER_OS) .

docker-buildx-builder-cockroachdb:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_BUILDER_COCKROACH_BASE_IMAGE) \
	  	--build-arg COCKROACH_VERSION=$(DOCKER_BUILDER_COCKROACH_VERSION) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-cockroachdb/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)builder-cockroachdb-$(DOCKER_OS) .

docker-buildx-builder-standalone:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_USERNAME)/builder-cropdroid-base-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-standalone \
		-t $(DOCKER_ENDPOINT)builder-cropdroid-standalone-$(DOCKER_OS) .

docker-buildx-builder-cluster:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_USERNAME)/builder-cropdroid-base-$(DOCKER_OS) \
		--push \
		-f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster \
		-t $(DOCKER_ENDPOINT)builder-cropdroid-cluster-$(DOCKER_OS) .

docker-buildx-cropdroid-standalone:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg STANDALONE_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-standalone-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-standalone-$(DOCKER_OS) .

docker-buildx-cropdroid-cluster:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-cluster-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=$(DOCKER_USERNAME)/builder-rocksdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) \
		-t $(DOCKER_ENDPOINT)cropdroid-cluster-$(DOCKER_OS) .

docker-buildx-cockroachdb:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg COCKROACHDB_BUILDER=builder-cockroachdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-t $(DOCKER_ENDPOINT)cockroachdb-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-$(DOCKER_OS) .

docker-buildx-builders: docker-buildx-rocksdb \
	docker-buildx-builder-cockroachdb \
	docker-buildx-builder-standalone \
	docker-buildx-builder-cluster

docker-buildx-cropdroid: docker-buildx-cropdroid-standalone \
	docker-buildx-cropdroid-cluster

docker-buildx-all: docker-buildx-base \
	docker-buildx-builders \
	docker-buildx-cropdroid	\
	docker-buildx-cockroachdb

docker-images: docker-build-all docker-buildx-all

docker-local:
	docker tag $(DOCKER_IMAGE) $(DOCKER_LOCAL_REGISTRY)/$(DOCKER_IMAGE)
	docker push $(DOCKER_LOCAL_REGISTRY)/$(DOCKER_IMAGE)



# --------------- #
# Docker Registry #
# --------------- #
docker-registry-start:
	#docker daemon --insecure-registry $(DOCKER_REGISTRY) --mtu 1400
	docker run -d \
		-p 5000:5000 \
		--restart=always \
		--name registry \
		-v "${PWD}/devops/registry:/data" \
		registry:2

docker-registry-start-https:
	docker run -d \
		--restart=always \
		--name registry \
		-v "${PWD}/devops/registry:/data" \
		-v "${PWD}/devops/registry/certs:/certs" \
		-v "${PWD}/devops/registry/auth:/auth" \
		-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
		-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
		-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
		-e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
		-p 443:443 \
		registry:2
# -e "REGISTRY_AUTH=htpasswd" \
# -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
# -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \

docker-registry-htpasswd:
	AUTHPATH=$(DEVOPS_HOME)/registry/auth ; \
	mkdir -p $$AUTHPATH ; \
	htpasswd -Bbn $(DOCKER_USERNAME) $(DOCKER_PASSWORD) > $$AUTHPATH/htpasswd

docker-registry-certs:
	mkdir -p $(DEVOPS_HOME)/registry/certs
	openssl req \
	-newkey rsa:4096 -nodes -sha256 -keyout $(DEVOPS_HOME)/registry/certs/domain.key \
	-addext "subjectAltName = DNS:$(DOCKER_REGISTRY_DNS)" \
	-x509 -days 365 -out $(DEVOPS_HOME)/registry/certs/domain.crt
	sudo cp $(DEVOPS_HOME)/registry/certs/domain.crt /usr/local/share/ca-certificates/$(DOCKER_REGISTRY_DNS).crt
	sudo update-ca-certificates

docker-registry-catalog:
	@curl -X GET http://$(DOCKER_REGISTRY)/v2/_catalog

docker-registry-login:
#	docker login $(DOCKER_REGISTRY)
	docker login $(DOCKER_REGISTRY_DNS)

docker-registry-login-github:
	echo $(GITHUB_TOKEN) | docker login https://ghcr.io -u $(DOCKER_USERNAME) --password-stdin



# -------- #
# Minikube #
# -------- #
# https://shashanksrivastava.medium.com/how-to-set-up-minikube-to-use-your-local-docker-registry-10a5b564883
# --insecure-registry "$(DOCKER_SUBNET)"
minikube-start:
	minikube \
		--memory 8192 \
		--cpus $(CORES) \
		--driver=docker \
		--insecure-registry "$(DOCKER_SUBNET)" \
		start
	minikube addons enable registry
	$(MAKE) minikube-registry-port-forward

minikube-registry-port-forward:
	NODE_NAME=$(shell kubectl get pods -n kube-system -l actual-registry=true | cut -d ' ' -f1 | tail -n 1) ; \
	kubectl port-forward --namespace kube-system $$NODE_NAME 5000:5000 &

minikube-app-port-forward:
	NODE_NAME=$(shell kubectl get pods -n cropdroid-local -l actual-registry=true | cut -d ' ' -f1 | tail -n 1) ; \
	kubectl port-forward --namespace kube-system $$NODE_NAME 5000:5000 &

minikube-dev: minikube-start
	direnv reload
	$(MAKE) docker-images

#minikube-docker-ps:
#	eval `minikube -p minikube docker-env` && docker ps -a





# ---------- #
# Kubernetes #
# ---------- #
k8s-create-registry-secret:
	kubectl create secret docker-registry regcred \
		--docker-server=$(DOCKER_REGISTRY) \
		--docker-username=$(DOCKER_USERNAME) \
		--docker-password=$(DOCKER_PASSWORD) \
		--docker-email=$(DOCKER_EMAIL)
	#kubectl create secret generic regcred \
    #	--from-file=.dockerconfigjson=ENV['HOME']/.docker/config.json \
    #	--type=kubernetes.io/dockerconfigjson

k8s-secret-local-registry:
	kubectl create secret docker-registry local-registry \
		--docker-server=$(DOCKER_REGISTRY) \
		--docker-username=$(DOCKER_USERNAME) \
		--docker-password=$(DOCKER_PASSWORD) \
		--docker-email=$(DOCKER_EMAIL)
	#DOCKER_REGISTRY=registry.cropdroid.local DOCKER_USERNAME=admin DOCKER_PASSWORD=secret make k8s-secret-local-registry

k8s-deploy-cluster:
	kubectl apply -k devops/kubernetes/cluster-local/overlays/$(ENV)

k8s-delete-cluster:
	kubectl delete -k devops/kubernetes/cluster-local/overlays/$(ENV)

k8s-redeploy-cluster: k8s-delete-cluster k8s-deploy-cluster



sdimage:
	$(shell bash -c 'read -s -p "Writing image $(RPI_IMAGE_ARTIFACT) to $(RPI_SDCARD). Press any key to continue or CTRL+C to abort!"')
	-sudo -E umount /media/$(USER)/rootfs
	-sudo -E umount /media/$(USER)/boot
	sudo dd bs=4M if=$(RPI_IMAGE_ARTIFACT) of=$(RPI_SDCARD) conv=fsync



# ------ #
# Packer #
# ------ #
packer-raspios:
	cd $(DEVOPS_HOME) && sudo -E packer build \
	    -var "aws_access_key_id=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "aws_region=${AWS_REGION}" \
		-var "aws_profile=${AWS_PROFILE}" \
		-var "local_user=$(USER)" \
		-var "appname=$(APP)" \
		-var "apptype=$(APPTYPE)" \
		-var "appenv=$(ENV)" \
		-var "hostname=$(HOSTNAME)" \
		-var "cropdroid_binary_type=$(APPTYPE)" \
		-var "cropdroid_home=$(DEPLOY_HOME)" \
		-var "eth0_cidr=$(ETH0_CIDR)" \
		-var "eth0_routers=$(ETH0_ROUTERS)" \
		-var "eth0_dns=$(ETH0_DNS)" \
		-var "wlan_cidr=$(WLAN_CIDR)" \
		-var "wlan_routers=$(WLAN_ROUTERS)" \
		-var "wlan_dns=$(WLAN_DNS)" \
		-var "wlan_ssid=$(WLAN_SSID)" \
		-var "wlan_psk=$(WLAN_PSK)" \
		-var "wlan_key_mgmt=$(WLAN_KEY_MGMT)" \
		-var "wlan_country=$(WLAN_COUNTRY)" \
		-var "datastore=sqlite" \
		-var "cropdroid_binary=cropdroid-$(APPTYPE)-arm" \
	    packer/raspios-$(ENV).json
	sudo -E cp $(DEVOPS_HOME)/$(RPI_BASE_IMAGE)/image $(RPI_IMAGE_ARTIFACT)
	sudo chown $(USER) $(RPI_IMAGE_ARTIFACT)

packer-raspios64:
	cd $(DEVOPS_HOME) && sudo -E packer build \
		-var "aws_access_key_id=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "aws_region=${AWS_REGION}" \
		-var "aws_profile=${AWS_PROFILE}" \
		-var "local_user=$(USER)" \
		-var "appname=$(APP)" \
		-var "apptype=$(APPTYPE)" \
		-var "appenv=$(ENV)" \
		-var "hostname=$(HOSTNAME)" \
		-var "cropdroid_home=$(DEPLOY_HOME)" \
		-var "eth0_cidr=$(ETH0_CIDR)" \
		-var "eth0_routers=$(ETH0_ROUTERS)" \
		-var "eth0_dns=$(ETH0_DNS)" \
		-var "wlan_cidr=$(WLAN_CIDR)" \
		-var "wlan_routers=$(WLAN_ROUTERS)" \
		-var "wlan_dns=$(WLAN_DNS)" \
		-var "wlan_ssid=$(WLAN_SSID)" \
		-var "wlan_psk=$(WLAN_PSK)" \
		-var "wlan_key_mgmt=$(WLAN_KEY_MGMT)" \
		-var "wlan_country=$(WLAN_COUNTRY)" \
		-var "datastore=sqlite" \
		-var "cropdroid_binary=cropdroid-$(APPTYPE)-arm64" \
		-var "image_name=$(RPI_BASE_IMAGE)" \
	    packer/raspios64-2-$(ENV).json
	sudo -E cp $(DEVOPS_HOME)/output-$(RPI_BASE_IMAGE)-$(ENV)/image $(RPI_IMAGE_ARTIFACT)
	sudo chown $(USER) $(RPI_IMAGE_ARTIFACT)

packer:
	cd $(DEVOPS_HOME) && sudo -E packer build \
		-var "aws_access_key_id=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "aws_region=${AWS_REGION}" \
		-var "aws_profile=${AWS_PROFILE}" \
		-var "local_user=$(USER)" \
		-var "appname=$(APP)" \
		-var "apptype=$(APPTYPE)" \
		-var "appenv=$(ENV)" \
		-var "hostname=$(HOSTNAME)" \
		-var "cropdroid_home=$(DEPLOY_HOME)" \
		-var "eth0_cidr=$(ETH0_CIDR)" \
		-var "eth0_routers=$(ETH0_ROUTERS)" \
		-var "eth0_dns=$(ETH0_DNS)" \
		-var "wlan_cidr=$(WLAN_CIDR)" \
		-var "wlan_routers=$(WLAN_ROUTERS)" \
		-var "wlan_dns=$(WLAN_DNS)" \
		-var "wlan_ssid=$(WLAN_SSID)" \
		-var "wlan_psk=$(WLAN_PSK)" \
		-var "wlan_key_mgmt=$(WLAN_KEY_MGMT)" \
		-var "wlan_country=$(WLAN_COUNTRY)" \
		-var "datastore=sqlite" \
		-var "cropdroid_binary=cropdroid-$(APPTYPE)-arm64" \
		-var "image_name=$(RPI_BASE_IMAGE)" \
	    packer/$(PACKER_FILE)
	sudo -E cp $(DEVOPS_HOME)/output-$(RPI_BASE_IMAGE)-$(ENV)/image $(RPI_IMAGE_ARTIFACT)
	sudo chown $(USER) $(RPI_IMAGE_ARTIFACT)


https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2021-05-28/2021-05-07-raspios-buster-arm64.zip

packer-ubuntu-arm64:
	cd $(DEVOPS_HOME) && sudo -E packer build -var "cropdroid_binary_type=$(APPTYPE)" packer/ubuntu-20.10-arm64-$(ENV).json
	sudo -E cp $(DEVOPS_HOME)/output-$(RPI_BASE_IMAGE)-$(ENV)/image $(RPI_IMAGE_ARTIFACT)
	sudo chown $(USER) $(RPI_IMAGE_ARTIFACT)

packer-docker-ubuntu-arm64:
	cd $(DEVOPS_HOME) && sudo -E packer build -var "cropdroid_binary_type=$(APPTYPE)" packer/docker-ubuntu-arm64.json



ansible: ansible-rsync
	#rsync -avr -e "ssh -l $(TARGET_USER)" $(DEVOPS_HOME)/ansible/ $(TARGET_USER)@$(TARGET_HOST):ansible
	ssh $(TARGET_USER)@$(TARGET_HOST) ansible-playbook \
		ansible/playbook.yml \
		-e aws_access_key_id=$(AWS_ACCESS_KEY_ID) \
		-e aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY) \
		-e aws_region=${AWS_REGION} \
		-e aws_profile=${AWS_PROFILE} \
		-e appname=$(APP) \
		-e apptype=$(APPTYPE) \
		-e appenv=$(ENV) \
		-e hostname=$(TARGET_HOST) \
		-e cropdroid_home=$(DEPLOY_HOME) \
		-e wlan_ssid=$(WLAN_SSID) \
		-e wlan_psk=$(WLAN_PSK) \
		-e wlan_key_mgmt=$(WLAN_KEY_MGMT) \
		-e wlan_country=$(WLAN_COUNTRY) \
		-e datastore=sqlite

ansible-rsync:
	rsync -avr -e "ssh -l $(TARGET_USER)" $(DEVOPS_HOME)/ansible/* $(TARGET_USER)@$(TARGET_HOST):ansible

ansible-artifacts: build-arm
	cp cropdroid $(DEVOPS_HOME)/ansible/roles/$(APP)/files/$(APP)-arm
	cp -R keys/ $(DEVOPS_HOME)/ansible/roles/$(APP)/files
	cp -R public_html/ $(DEVOPS_HOME)/ansible/roles/$(APP)/files





# https://downloads.raspberrypi.org/raspbian/images/
# https://github.com/dhruvvyas90/qemu-rpi-kernel
# -hda $(DEVOPS_HOME)/raspios/2020-05-27-raspios-buster-armhf.img
qemu-buster:
	qemu-system-arm \
		-M versatilepb \
		-cpu arm1176 \
		-m 256 \
		-hda $(RPI_IMAGE_ARTIFACT) \
		-net user,hostfwd=tcp::5022-:22 \
		-dtb $(RPI_KERNEL)/versatile-pb-buster.dtb \
		-kernel $(RPI_KERNEL)/kernel-qemu-4.19.50-buster \
		-append 'root=/dev/sda2 panic=1' \
		-no-reboot

qemu-stretch:
	qemu-system-arm \
		-M versatilepb \
		-cpu arm1176 \
		-m 256 \
		-hda $(DEVOPS_HOME)/raspios/2019-04-08-raspbian-stretch.img \
		-net user,hostfwd=tcp::5022-:22 \
		-dtb $(RPI_KERNEL)/versatile-pb.dtb \
		-kernel $(RPI_KERNEL)/kernel-qemu-4.14.79-stretch \
		-append 'root=/dev/sda2 panic=1' \
		-no-reboot

qemu-buster-arm64:
	#-hda $(IMAGES_HOME)/2020-05-27-raspios-buster-arm64-test.img
	#root=LABEL=root ro rootwait console=ttyS1,115200
	#-cpu cortex-a72 
	#-kernel $(SOURCES)/rpi4kernel/linux/kernel-build/arch/arm64/boot/Image
	#-net user,hostfwd=tcp::5022-:22
	#-serial stdio
	#-append 'rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0 rootwait memtest=1 panic=1'
	qemu-system-aarch64 \
		-kernel /home/jhahn/sources/rpi4kernel/kernel8.img \
		-dtb /home/jhahn/sources/rpi4kernel/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb \
		-cpu cortex-a53 \
		-M raspi3 \
		-m 256 \
		-serial stdio \
		-hda $(DEVOPS_HOME)/output-docker-ubuntu-20.04.01-arm64/image \
		-append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0 rootwait memtest=1" \
		-drive file=$(DEVOPS_HOME)/output-docker-ubuntu-20.04.01-arm64/live-image,format=raw,if=sd \
		-no-reboot

qemu-arm64:
	#-drive file=devops/output-2020-05-27-raspios-buster-arm64-dev/base-new,if=none,id=drive0,cache=writeback
	qemu-system-aarch64 \
		-nographic \
		-machine raspi3 \
		-m 4096 \
		-cpu cortex-a72 \
		-kernel /home/jhahn/sources/rpi4kernel/kernel8.img \
		-dtb /home/jhahn/sources/rpi4kernel/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb \
		-hda $(DEVOPS_HOME)/output-2020-05-27-raspios-buster-arm64-dev/base-new
		-netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 \
		-device virtio-net-pci,netdev=vnet \
		-no-reboot

qemu-ubuntu-2010:
	qemu-system-aarch64 \
		-smp 4 \
		-M raspi3 \
		-m 1G \
		-dtb $(SOURCES)/qemu-rpi-kernel/native-emuation/dtbs/bcm2710-rpi-3-b-plus.dtb \
		-kernel $(SOURCES)/rpi4kernel/kernel8.img \
		-append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 rootdelay=1" \
		-sd $(DEVOPS_HOME)/output-ubuntu-20.10-arm64-dev/test \
		-serial stdio \
		-no-reboot

#-sd $(DEVOPS_HOME)/output-ubuntu-20.10-arm64-dev/test \
#-dtb $(SOURCES)/qemu-rpi-kernel/native-emuation/dtbs/bcm2710-rpi-3-b-plus.dtb \

# https://wiki.ubuntu.com/ARM64/QEMU
# https://lanyaplab.com/index.php/2020/06/08/how-to-install-ubuntu-server-for-arm-in-a-qemu-aarch64-virtual-machine/
# https://github.com/2bdkid/debian-rpi3-arm64-guide
# https://github.com/2bdkid/debian-rpi4-arm64-guide
qemu-ubuntu-arm64:
	#qemu-img create -f qcow2 $(IMAGES_HOME)/ubuntu-20.04.1-arm64.qcow2 16G
	qemu-system-aarch64 \
		-m 4096 \
		-cpu cortex-a57 \
		-M virt \
		-nographic \
		-drive if=pflash,format=raw,file=$(IMAGES_HOME)/flash0.img,readonly \
		-drive if=pflash,format=raw,file=$(IMAGES_HOME)/flash1.img \
		-drive format=raw,file=$(shell pwd)/devops/output-ubuntu-20.10-arm64-dev/image,if=none,id=drv0 \
		-device virtio-net-pci,netdev=net0,romfile="" \
		-netdev type=user,id=net0 \
		-device virtio-blk-pci,drive=drv0 \
		-object rng-random,filename=/dev/urandom,id=rng0 \
		-device virtio-rng-pci,rng=rng0 \
		-device virtio-scsi 
		#-device scsi-cd,drive=cd 
		#-drive if=none,id=cd,file=$(IMAGES_HOME)/ubuntu-20.04.1-live-server-arm64.iso

qemu-ubuntu-aarch64:
	qemu-system-aarch64 \
		-nographic \
		-machine virt \
		-cpu cortex-a57 \
		-m 1G \
		-drive if=pflash,format=raw,file=$(IMAGES_HOME)/flash0.img,readonly \
		-drive if=pflash,format=raw,file=$(IMAGES_HOME)/flash1.img \
		-drive format=raw,file=$(DEVOPS_HOME)/output-ubuntu-20.10-arm64-dev/image,if=none,id=drv0 \
		-device virtio-blk-device,drive=drv0 \
		-no-reboot


qemu-cluster:
	$(SCRIPTS)/qemu-cluster.sh

qemu:
	qemu-system-arm \
		-M versatilepb \
		-cpu arm1176 \
		-m 256 \
		-hda $(RPI_IMAGE_ARTIFACT) \
		-net user,hostfwd=tcp::5022-:22 \
		-dtb $(RPI_KERNEL)/versatile-pb.dtb \
		-kernel $(RPI_KERNEL)/kernel-qemu-4.14.79-stretch \
		-append "root=/dev/sda2 panic=1" \
		-no-reboot



# -------------------------#
# Docker debugging helpers #
# -------------------------#
docker-network:
	docker network create --subnet=$(DOCKER_SUBNET) cropnet

docker-network-clean:
	docker network rm cropnet

#docker-standalone-defaults:
#	docker run -it --name cropdroid -p 80:80 cropdroid-standalone

#docker-clean:
#	- docker stop cropdroid-$(APPTYPE)
#	- docker rm -f cropdroid-$(APPTYPE)

docker-cropdroid-cluster-clean:
	- docker stop cropdroid-d1-n1 cropdroid-d1-n2 cropdroid-d1-n3
	- docker rm -f cropdroid-d1-n1 cropdroid-d1-n2 cropdroid-d1-n3
	- tmux kill-server

docker-run-cockroachdb-cluster:
	#docker network create -d bridge cropnet
	docker run -d \
		--name=roach1 \
		--hostname=roach1 \
		--net=cropnet \
		-p 26257:26257 -p 8080:8080  \
		-v "${PWD}/db/cockroach-data/roach1:/cockroach/cockroach-data"  \
		cockroachdb/cockroach start \
		--insecure \
		--join=roach1,roach2,roach3
	docker run -d \
		--name=roach2 \
		--hostname=roach2 \
		--net=cropnet \
		-v "${PWD}/db/cockroach-data/roach2:/cockroach/cockroach-data" \
		cockroachdb/cockroach start \
		--insecure \
		--join=roach1,roach2,roach3
	docker run -d \
		--name=roach3 \
		--hostname=roach3 \
		--net=cropnet \
		-v "${PWD}/db/cockroach-data/roach3:/cockroach/cockroach-data" \
		cockroachdb/cockroach start \
		--insecure \
		--join=roach1,roach2,roach3
	docker exec -it roach1 ./cockroach init --insecure
	./$(APP) config --init --datastore cockroach
	docker exec -it roach1 ./cockroach sql --insecure

docker-cockroachdb-log:
	docker logs roach1

docker-cockroachdb-clean:
	docker stop roach1 roach2 roach3
	docker rm roach1 roach2 roach3
	sudo rm -rf db/cockroach-data/*

docker-cluster-init:
	#-v "${PWD}/cropdroid-data/cropdroid-d1-n1:/cropdroid-data"
	#-v "${PWD}/keys:/keys"
	docker run -d \
		--name=cropdroid-init \
		--hostname=cropdroid-init \
		--net=cropnet \
		-p 8091:8091 \
		cropdroid /cropdroid config --init --debug --datastore cockroach --datastore-host roach1

docker-run-cropdroid-cluster:
	#-v "${PWD}/cropdroid-data/cropdroid-d1-n1:/cropdroid-data"
	#-v "${PWD}/keys:/keys"
	docker run -d \
		--name=cropdroid-d1-n1 \
		--hostname=cropdroid-d1-n1 \
		--ip $(DOCKER_NODE1_IP) \
		--net=cropnet \
		-p 8091:8091 \
		cropdroid-cluster $(DEPLOY_HOME)/cropdroid cluster --debug \
			--ssl=false \
			--port 8091 \
			--datastore cockroach \
			--datastore-host roach1 \
			--enable-registrations \
			--listen $(DOCKER_NODE1_IP) \
			--raft "$(DOCKER_NODE1_IP):60020,$(DOCKER_NODE2_IP):60021,$(DOCKER_NODE3_IP):60022"
	docker run -d \
		--name=cropdroid-d1-n2 \
		--hostname=cropdroid-d1-n2 \
		--ip $(DOCKER_NODE2_IP) \
		--net=cropnet \
		-p 8092:8092 \
		cropdroid-cluster $(DEPLOY_HOME)/cropdroid cluster --debug \
			--ssl=false \
			--port 8092 \
			--datastore cockroach \
			--datastore-host roach2 \
			--enable-registrations \
			--listen $(DOCKER_NODE2_IP) \
			--gossip-peers "$(DOCKER_NODE1_IP):60010" \
			--gossip-port 60011 \
			--raft "$(DOCKER_NODE1_IP):60020,$(DOCKER_NODE2_IP):60021,$(DOCKER_NODE3_IP):60022" \
			--raft-port 60021
	docker run -d \
		--name=cropdroid-d1-n3 \
		--hostname=cropdroid-d1-n3 \
		--ip $(DOCKER_NODE3_IP) \
		--net=cropnet \
		-p 8093:8093 \
		cropdroid-cluster $(DEPLOY_HOME)/cropdroid cluster --debug \
			--ssl=false \
			--port 8093 \
			--datastore cockroach \
			--datastore-host roach3 \
			--enable-registrations \
			--listen $(DOCKER_NODE3_IP) \
			--gossip-peers "$(DOCKER_NODE1_IP):60010,$(DOCKER_NODE2_IP):60011" \
			--gossip-port 60012 \
			--raft "$(DOCKER_NODE1_IP):60020,$(DOCKER_NODE2_IP):60021,$(DOCKER_NODE3_IP):60022" \
			--raft-port 60022
	$(SCRIPTS)/docker-cluster-tmux.sh

docker-run-cluster: docker-run-cockroachdb-cluster docker-run-cropdroid-cluster

# Need to refactor build tags / naming conflicts so cluster binaries can also run standalone
#docker-cropdroid-cluster-standalone:
#	docker run -d \
#		--name=cropdroid-cluster-standalone \
#		--hostname=cropdroid-cluster-standalone \
#		--ip $(DOCKER_NODE3_IP) \
#		--net=cropnet \
#		-p 8093:8093 \
#		-v "${PWD}/cropdroid-data/cropdroid-cluster-standalone:/cropdroid-data" \
#		-v "${PWD}/keys:/keys" \
#		cropdroid /cropdroid cluster --debug \
#			--data-dir /cropdroid-data \
#			--log-dir / \
#			--log-file /cropdroid.log \
#			--keys /keys \
#			--ssl=false \
#			--port 8093 \
#			--datastore memory \
#			--enable-registrations

docker-run-cropdroid-standalone:
	docker run -d \
		--name=cropdroid-standalone \
		--hostname=cropdroid \
		--ip $(DOCKER_NODE1_IP) \
		--net=cropnet \
		-p 8091:8091 \
		-v "${PWD}/cropdroid-data/cropdroid:/cropdroid-data" \
		-v "${PWD}/keys:/keys" \
		cropdroid-standalone $(DEPLOY_HOME)/$(APP) standalone --debug \
			--data-dir /cropdroid-data \
			--log-dir / \
			--log-file /cropdroid.log \
			--keys /keys \
			--ssl=false \
			--port 8091 \
			--enable-registrations



# https://blog.tekspace.io/deploying-kubernetes-dashboard-in-k3s-cluster/
k3s-dashbaord:
	ssh $(TARGET_USER)@$(TARGET_HOST) sudo k3s kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
	$(BROWSER) https://$(TARGET_HOST):32637/#/overview?namespace=default
