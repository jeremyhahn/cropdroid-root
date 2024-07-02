ORG                     := automatethethingsllc
TARGET_OS               := linux
TARGET_ARCH             := $(shell uname -m)

CORES                   ?= $(shell nproc)
ARCH                    := $(shell go env GOARCH)
OS                      := $(shell go env GOOS)
BUILDDIR                := $(shell pwd)
TIMEZONE                ?= $(shell cat /etc/timezone)
TIMESTAMP               := $(shell date +"%Y-%m-%d_%H-%M-%S")
NUMPROC                 := $(shell nproc)
BROWSER                 ?= /usr/bin/firefox
#LOCAL_ADDRESS           ?= $(shell hostname -I | cut -d " " -f1)
LOCAL_ADDRESS           ?= localhost

#GOBIN                   := $(shell dirname `which go`)
GOBIN                   := $(HOME)/go/bin

CROPDROID_SRC           ?= src/go-cropdroid
CROPDROID_DATASTORE     ?= memory

APP                     := cropdroid
APPTYPE					?= standalone
ENV             		?= dev
TARGET_USER             ?= pi
TARGET_HOST             ?= cropdroid1
TARGET_ARCH				?= arm64
WEBSERVER_USER          ?= www-data

HOSTNAME                ?= cropdroid1
ETH0_CIDR               ?= 192.168.0.131/24
ETH0_ROUTERS            ?= 192.168.0.1
ETH0_DNS                ?= 192.168.0.1
WLAN_CIDR               ?= 192.168.100.131/24
WLAN_ROUTERS            ?= 192.168.100.1
WLAN_DNS                ?= 192.168.100.1
WLAN_SSID               ?= MJ_5G
WLAN_PSK                ?= Cropdroid1
WLAN_KEY_MGMT           ?= WPA-PSK
WLAN_COUNTRY            ?= US

CLUSTER_PEER1           ?= cropdroid-c1-n0
CLUSTER_PEER2           ?= cropdroid-c1-n1
CLUSTER_PEER3           ?= cropdroid-c1-n2
CLUSTER_RAFT_PORT       ?= 60020
CLUSTER_RAFT_PEERS      ?= $(CLUSTER_PEER1):$(CLUSTER_RAFT_PORT),$(CLUSTER_PEER2):$(CLUSTER_RAFT_PORT),$(CLUSTER_PEER3):$(CLUSTER_RAFT_PORT)
CLUSTER_GOSSIP_PORT     ?= 60010
CLUSTER_GOSSIP_PEERS    ?= $(CLUSTER_PEER1):$(CLUSTER_GOSSIP_PORT),$(CLUSTER_PEER2):$(CLUSTER_GOSSIP_PORT),$(CLUSTER_PEER3):$(CLUSTER_GOSSIP_PORT)

COCKROACHDB_LISTEN_ADDR ?= localhost:26257
COCKROACHDB_HTTP_PORT   ?= $(CLUSTER_PEER1):8080
COCKROACHDB_JOIN_FLAG   ?= $(CLUSTER_PEER1):26257,$(CLUSTER_PEER2):26257,$(CLUSTER_PEER3):26257

SOURCES                 ?= $(HOME)/sources
DEVOPS_HOME             ?= $(PWD)/devops
FIRMWARE_HOME           ?= $(HOME)/eclipse-workspace
IMAGES_HOME             ?= $(DEVOPS_HOME)/images
DEPLOY_HOME             ?= /opt/$(APP)
SCRIPTS_HOME            ?= $(DEVOPS_HOME)/scripts

# Required by Ansible playbook and Packer builds
AWS_ACCESS_KEY_ID       ?=
AWS_SECRET_ACCESS_KEY   ?=
AWS_REGION              ?= us-east-1
AWS_PROFILE             ?= default

# Required by docker targets
DOCKER_HOME             ?= $(DEVOPS_HOME)/docker
DOCKER_REGISTRY         ?= docker.io
DOCKER_USERNAME         ?= jeremyhahn
DOCKER_PASSWORD         ?=
DOCKER_EMAIL            ?= root@localhost
DOCKER_SUBNET           ?= 172.18.0.0/16
DOCKER_NODE1_IP         ?= 172.18.0.10
DOCKER_NODE2_IP         ?= 172.18.0.11
DOCKER_NODE3_IP         ?= 172.18.0.12
DOCKER_OS               ?= ubuntu
DOCKER_OS_TAG		    ?= latest
DOCKER_IMAGE            ?= $(DOCKER_OS):$(DOCKER_OS_TAG)
DOCKER_ALPINE_IMAGE     ?= alpine:latest
DOCKER_GOLANG_IMAGE     ?= golang:buster

DOCKER_BUILDER_ROCKSDB_BASE_IMAGE ?= ubuntu:20.10
DOCKER_BUILDER_ROCKSDB_VERSION    ?= 6.10.fb

DOCKER_BUILDER_COCKROACH_BASE_IMAGE ?= golang:latest
DOCKER_BUILDER_COCKROACH_VERSION    ?= v21.1.1

DOCKER_BUILDX_TAG_PREFIX ?= $(DOCKER_REGISTRY)/$(DOCKER_USERNAME)/

ifeq ($(DOCKER_LOCAL),1)
 	DOCKER_BUILD_TAG_PREFIX =
else
	DOCKER_BUILD_TAG_PREFIX ?= $(DOCKER_USERNAME)/
endif

PACKER_FILE              ?= 2024-03-15-raspios-bookworm-arm64.json
PACKER_BUILDER_RASPIOS64 ?= 2024-03-15-raspios-bookworm-arm64
PACKER_BUILDER_UBUNTU64  ?= ubuntu-20.04.01-arm64
PACKER_BUILDER           ?= $(PACKER_BUILDER_RASPIOS64)

ANSIBLE_HOME             ?= $(DEVOPS_HOME)/ansible
ANSIBLE_CROPDROID 		 ?= $(ANSIBLE_HOME)/roles/$(APP)
ANSIBLE_CROPDROID_FILES  ?= $(ANSIBLE_CROPDROID)/files
ANSIBLE_FIRMWARE         ?= $(ANSIBLE_CROPDROID_FILES)/firmware
#ANSIBLE_BOOTLOADER       ?= $(ANSIBLE_CROPDROID_FILES)/bootloaders

IMAGE_NAME		        ?= $(HOSTNAME)-$(APPTYPE)-$(ENV)
IMAGE_FILENAME          ?= $(IMAGE_NAME).img

RPI_KERNEL              ?= $(SOURCES)/qemu-rpi-kernel
RPI_IMAGE_ARTIFACT      ?= $(IMAGES_HOME)/$(IMAGE_FILENAME)
RPI_SDCARD              ?= /dev/sda



# Performance testing
API_ENDPOINT               ?= http://localhost:8091
API_WS_ENDPOINT            ?= ws://localhost:8091
API_UID                    ?= 1
API_USERNAME               ?= admin
API_PASSWORD               ?= cropdroid
API_AUTH_TYPE              ?= 0 # 0 = local auth, 1 = google auth
#API_JWT_TOKEN             ?= eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWQiOjAsInVpZCI6MiwiZW1haWwiOiJtYWlsQGplcmVteWhhaG4uY29tIiwib3JnYW5pemF0aW9ucyI6Ilt7XCJpZFwiOjAsXCJuYW1lXCI6XCJcIixcImZhcm1zXCI6W3tcImlkXCI6MixcIm5hbWVcIjpcIkZpcnN0IFJvb21cIixcInJvbGVzXCI6bnVsbH1dLFwicm9sZXNcIjpbXCJhZG1pblwiXSxcImxpY2Vuc2VcIjpudWxsfV0iLCJleHAiOjE2NjQwNDI1NTIsImlhdCI6MTYzMjQ4NDk1MiwiaXNzIjoiY3JvcGRyb2lkIn0.LF06h59lh2JluA3dmk7ILCgAXxJHlpsD1GEt3mCEftkZr1rEJ-5IBXCFc2SgFZvZgQ5cKDQLibBUqfqhpinPydZf7YozYKFVzsH1W7dd0E6XUpSQ4WA2rdR03KS6P_fCS1KGxwkriFPhTxZ5y6TFSoV8RZR1NP7KYkzYPHD6m4f1G_-VmSg4QNIgT47lcgEQm4bmoR57QnVj0BWfGuuNVzAF8YCFCielg0uLmD3Ph4zl6ovmIm5g3jkGCwCavO02jT3Su-YaVO3AVW2e_-3WpRomCFbX8gagPI22zCEruLnormVxYXiFXTmQyRLF5uY0uEfAoDpdEIIv1J9lm7vzPw
#API_JWT_TOKEN              ?= eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWQiOjAsInVpZCI6MSwiZW1haWwiOiJhZG1pbiIsIm9yZ2FuaXphdGlvbnMiOiJbe1wiaWRcIjowLFwibmFtZVwiOlwiXCIsXCJmYXJtc1wiOltdLFwicm9sZXNcIjpbXCJhZG1pblwiXSxcImxpY2Vuc2VcIjpudWxsfV0iLCJleHAiOjE2NjQwNTgzMjIsImlhdCI6MTYzMjUwMDcyMiwiaXNzIjoiY3JvcGRyb2lkIn0.qHCv86RMI228eL7WNumRG6pfnXw9QMLNH6xEmNHX2zewjmZU91praly6lVGLAb1Bcr5o9iUcYoT9AEOFfO-VbE-MTajpFrys_3eBPqe4LmzgCwpnrFMK-daL8dw5i6oRxelrV-7dPjfmmL_uBmKohSxlkU3Z9IXoayXR7KY_0c3NTTDbG4MxbmL1eRlQRSecVdPAqur9DbnWVjFL9kdYlF3GNq9uztQw2CnxezMX3ECESPPbKhrx2MnTiD9EIq_Ivj4kYdHrXYS6xh_H9T8v74W0Bsb4Wp-0jvMMZyTo0ZxLI48LcreZHOGlzhX4G_DGMeMtaYzYT0a0whn7muezWg
# cluster token
API_JWT_TOKEN              ?= eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWQiOjEsInVpZCI6ODg1NTM2Mjc2LCJlbWFpbCI6ImFkbWluIiwib3JnYW5pemF0aW9ucyI6IltdIiwiZmFybXMiOiJbe1wiaWRcIjoxMTMxNTY4MjYsXCJuYW1lXCI6XCJKQ3JvcFwiLFwicm9sZXNcIjpudWxsfV0iLCJleHAiOjE3MzcxNjE1NTMsImlhdCI6MTcwNTYwMzk1MywiaXNzIjoiY3JvcGRyb2lkIn0.VtGWxN1zEppk6y6dBwU-ReeXRsOT9BsK8Rfws73titype0t1kgNYBJ6SNALtSQgMzNBek6_3--zjR1GpZV_F-Au2TR-wXtGPe0E4XavEqpYmBiAOlNYdp5w_eq74KUIQJKmfHVTbJ-Gz-7lJxcvDFTyFUYwmNp51vlrklY9C9Oyc1ALttnKm4h-L_g4BM9ZvFD5ij4vW_c_xqqrZkmLKwM2VCUpM2_FKEjnyqEueseFkUqmszO0RiJfjmQlBDy7MQq2bW21n_BrvxfBMBcGKHchmqUCheFfUPwpiw0sKaXGZT0hZ8lV1rfT-xmsBwKHkIfOiz7ht2zIwSUJ30ILyuQ
API_FARM_ID                ?= 1
API_SYSTEM_ENDPOINT        ?= $(API_ENDPOINT)/system
API_STATE_ENDPOINT         ?= $(API_ENDPOINT)/api/v1/farms/$(API_FARM_ID)/state
API_CONFIG_ENDPOINT        ?= $(API_ENDPOINT)/api/v1/farms/$(API_FARM_ID)/config
API_DEVICES_ENDPOINT       ?= $(API_ENDPOINT)/api/v1/farms/$(API_FARM_ID)/devices
API_PROVISIONER_ENDPOINT   ?= $(API_ENDPOINT)/api/v1/provisioner/provision
API_LOGIN_ENDPOINT         ?= $(API_ENDPOINT)/api/v1/login
API_LOGIN_REFRESH_ENDPOINT ?= $(API_LOGIN_ENDPOINT)/refresh
API_FARMTICKER_ENDPOINT    ?= $(API_WS_ENDPOINT)/api/v1/farmticker/$(API_FARM_ID)


# Pebble DB
PEBBLE_CLUSTER_ID          ?= 0

default: minikube-start build-images



docker-build-env:
	@echo "-- Docker / Minikube Build Environment -- "
	@echo ""
	@echo "MINIKUBE_ACTIVE_DOCKERD=$(MINIKUBE_ACTIVE_DOCKERD)"
	@echo "DOCKER_BUILD_TAG_PREFIX=$(DOCKER_BUILD_TAG_PREFIX)"
	@echo "DOCKER_BUILDX_TAG_PREFIX=$(DOCKER_BUILDX_TAG_PREFIX)"
	@echo ""
	@docker images
	@echo ""
	@docker ps



room1:
	cd $(CROPDROID_SRC) && \
		make -j$(CORES) clean build-standalone-arm64-static
	ENV=prod \
	IMAGE_NAME=room1 \
	CROPDROID_DATASTORE=sqlite \
	$(MAKE) packer-raspios64 sdcard

room2:
	cd $(CROPDROID_SRC) && \
		make -j$(CORES) clean build-standalone-arm64-static
	ENV=prod \
	IMAGE_NAME=room2 \
	HOSTNAME=cropdroid2 \
	CROPDROID_DATASTORE=sqlite \
	ETH0_CIDR=192.168.0.132/24 \
	WLAN_CIDR=192.168.100.132/24 \
	$(MAKE) packer-raspios64 sdcard

rebuild-and-deploy:
	cd $(CROPDROID_SRC) && \
	make -j$(CORES) build-standalone-arm64-debug-static && \
	ssh $(TARGET_USER)@$(TARGET_HOST) 'sudo systemctl stop cropdroid' && \
	scp cropdroid $(TARGET_USER)@$(TARGET_HOST):/usr/local/bin/cropdroid && \
	ssh $(TARGET_USER)@$(TARGET_HOST) 'sudo systemctl start cropdroid'

remote-debug:
	cd $(CROPDROID_SRC) && \
	make -j$(CORES) build-standalone-arm64-debug-static && \
	ssh $(TARGET_USER)@$(TARGET_HOST) 'sudo systemctl stop cropdroid' && \
	scp cropdroid $(TARGET_USER)@$(TARGET_HOST):/usr/local/bin/cropdroid && \
	ssh $(TARGET_USER)@$(TARGET_HOST) \
	'sudo /home/$(TARGET_USER)/go/bin/dlv --listen=:40000 --headless=true --api-version=2 --accept-multiclient exec /usr/local/bin/cropdroid -- $(APPTYPE) --debug --home $(DEPLOY_HOME) --keys $(DEPLOY_HOME)/keys --data-dir $(DEPLOY_HOME)/db --port 80 --ssl=false --datastore $(CROPDROID_DATASTORE)'

remote-debug-kill:
	ssh $(TARGET_USER)@$(TARGET_HOST) 'sudo killall dlv'

firmware:
	scp -r $(ANSIBLE_FIRMWARE)/* $(TARGET_USER)@$(TARGET_HOST):$(DEPLOY_HOME)/firmware


# -------------- #
# Initialization #
# -------------- #
init:
	-mkdir src
	-git clone git@github.com:jeremyhahn/cropdroid-devops.git devops
	-git clone git@github.com:jeremyhahn/go-cropdroid.git src/go-cropdroid
	-git clone git@github.com:jeremyhahn/cropdroid-room.git src/cropdroid-room
	-git clone git@github.com:jeremyhahn/cropdroid-reservoir.git src/cropdroid-reservoir
	-git clone git@github.com:jeremyhahn/cropdroid-doser.git src/cropdroid-doser
	-git clone git@github.com:jeremyhahn/cropdroid-irrigation.git src/cropdroid-irrigation
	-git clone git@github.com:jeremyhahn/cropdroid-android.git src/cropdroid-android
	-mkdir terraform
	-git clone git@github.com:cropdroid/tf-env-root.git terraform/tf-env-root
	


# certs:
# 	mkdir -p keys/
# 	openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout keys/key.pem -out keys/cert.pem \
#           -subj "/C=US/ST=FL/L=West Palm Beach/O=Automate The Things, LLC/CN=localhost"
# 	openssl genrsa -out keys/rsa.key 2048
# 	openssl rsa -in keys/rsa.key -pubout -out keys/rsa.pub


# ------------- #
# Docker Images #
# ------------- #
docker-build-base:
	docker build \
	  --build-arg BASE_IMAGE=$(DOCKER_GOLANG_IMAGE) \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cropdroid-base-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-base/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-base-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-rocksdb:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=$(DOCKER_BUILDER_ROCKSDB_BASE_IMAGE) \
	  --build-arg ROCKSDB_VERSION=$(DOCKER_BUILDER_ROCKSDB_VERSION) \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-rocksdb-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-rocksdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-rocksdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cockroachdb:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=$(DOCKER_BUILDER_COCKROACH_BASE_IMAGE) \
	  --build-arg COCKROACH_VERSION=$(DOCKER_BUILDER_COCKROACH_VERSION) \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cockroachdb-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cockroachdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cockroachdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-standalone:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cropdroid-standalone-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-standalone .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-standalone-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-cluster-pebble:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  --build-arg ROCKSDB_IMAGE=builder-rocksdb-$(DOCKER_OS) \
	  --build-arg CLUSTER_DB=pebble \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cropdroid-cluster-pebble-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-cluster-pebble-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-cluster-rocksdb:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  --build-arg ROCKSDB_IMAGE=builder-rocksdb-$(DOCKER_OS) \
	  --build-arg CLUSTER_DB=rocksdb \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-builder-cropdroid-cluster-from-source:
	docker build \
	  --build-arg CORES=$(CORES) \
	  --build-arg BASE_IMAGE=builder-cropdroid-base-$(DOCKER_OS) \
	  --build-arg ROCKSDB_IMAGE=builder-rocksdb-$(DOCKER_OS) \
	  --build-arg CLUSTER_DB=rocksdb \
	  -t $(DOCKER_BUILD_TAG_PREFIX)builder-cropdroid-cluster-$(DOCKER_OS) \
	  -f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster-from-source .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=builder-cropdroid-cluster-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-standalone:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg STANDALONE_BUILDER=builder-cropdroid-standalone-$(DOCKER_OS) \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-standalone-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-standalone-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-cluster-pebble:
	docker build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-pebble-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=builder-rocksdb-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=pebble \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-pebble-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-pebble-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-cluster-rocksdb:
	docker build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=builder-rocksdb-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=rocksdb \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-rocksdb-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-rocksdb-$(DOCKER_OS) $(MAKE) docker-local
endif

docker-build-cropdroid-standalone-alpine:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg STANDALONE_BUILDER=builder-cropdroid-standalone-$(DOCKER_OS) \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-standalone-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-alpine .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-standalone-alpine $(MAKE) docker-local
endif

docker-build-cropdroid-cluster-pebble-alpine:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-pebble-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=pebble \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-pebble-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-alpine .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-pebble-alpine $(MAKE) docker-local
endif

docker-build-cropdroid-cluster-rocksdb-alpine:
	docker build \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg CLUSTER_BUILDER=builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=builder-rocksdb-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=rocksdb \
		-t $(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-rocksdb-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-alpine .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cropdroid-cluster-rocksdb-alpine $(MAKE) docker-local
endif

docker-build-cockroachdb-ubuntu:
	docker build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg COCKROACHDB_BUILDER=builder-cockroachdb-$(DOCKER_OS) \
		-t $(DOCKER_BUILD_TAG_PREFIX)cockroachdb-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-$(DOCKER_OS) .
ifdef DOCKER_PUSH
	DOCKER_IMAGE=cockroachdb-$(DOCKER_OS) $(MAKE) docker-local
endif

# Cockroach project builds arent static so they're failing in Alpine / MUSL
# docker-build-cockroachdb-alpine:
# 	docker build \
# 		--build-arg CORES=$(CORES) \
# 		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
# 		--build-arg COCKROACHDB_BUILDER=builder-cockroachdb-$(DOCKER_OS) \
# 		-t $(DOCKER_BUILD_TAG_PREFIX)cockroachdb-alpine \
# 		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-alpine .
# ifdef DOCKER_PUSH
# 	DOCKER_IMAGE=cockroachdb-alpine $(MAKE) docker-local
#endif

docker-build-builders: docker-build-builder-rocksdb \
	docker-build-builder-cockroachdb \
	docker-build-builder-cropdroid-standalone \
	docker-build-builder-cropdroid-cluster

docker-build-builder-cropdroid-cluster: docker-build-builder-cropdroid-cluster-pebble \
	docker-build-builder-cropdroid-cluster-rocksdb

docker-build-cropdroid-cluster: docker-build-cropdroid-cluster-pebble \
	docker-build-cropdroid-cluster-rocksdb

docker-build-cropdroid-cluster-alpine: docker-build-cropdroid-cluster-pebble-alpine \
	docker-build-cropdroid-cluster-rocksdb-alpine

docker-build-cropdroid: docker-build-cropdroid-standalone \
    docker-build-cropdroid-cluster

docker-build-cropdroid-alpine: docker-build-cropdroid-standalone-alpine \
	docker-build-cropdroid-cluster-alpine

docker-build-all: docker-build-base \
	docker-build-builders \
	docker-build-cockroachdb-ubuntu \
	docker-build-cropdroid \
	docker-build-cropdroid-alpine


docker-buildx-create:
	docker buildx create --use --name mybuilder --node build --driver-opt network=host

docker-buildx-base:
	docker buildx build \
	    --build-arg BASE_IMAGE=$(DOCKER_GOLANG_IMAGE) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-base/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-cropdroid-base-$(DOCKER_OS) .

docker-buildx-rocksdb:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_BUILDER_ROCKSDB_BASE_IMAGE) \
	  	--build-arg ROCKSDB_VERSION=$(DOCKER_BUILDER_ROCKSDB_VERSION) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-rocksdb/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-rocksdb-$(DOCKER_OS) .

docker-buildx-builder-cockroachdb:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_BUILDER_COCKROACH_BASE_IMAGE) \
	  	--build-arg COCKROACH_VERSION=$(DOCKER_BUILDER_COCKROACH_VERSION) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-cockroachdb/Dockerfile-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-cockroachdb-$(DOCKER_OS) .

docker-buildx-builder-standalone:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_USERNAME)/builder-cropdroid-base-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-standalone \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-cropdroid-standalone-$(DOCKER_OS) .

docker-buildx-builder-cluster-pebble:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_USERNAME)/builder-cropdroid-base-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=pebble \
		--push \
		-f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-cropdroid-cluster-pebble-$(DOCKER_OS) .

docker-buildx-builder-cluster-rocksdb:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_USERNAME)/builder-cropdroid-base-$(DOCKER_OS) \
		--build-arg CLUSTER_DB=rocksdb \
		--push \
		-f $(DOCKER_HOME)/builder-cropdroid/Dockerfile-cluster \
		-t $(DOCKER_BUILDX_TAG_PREFIX)builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) .

docker-buildx-cropdroid-standalone:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg STANDALONE_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-standalone-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-standalone-$(DOCKER_OS) .

docker-buildx-cropdroid-cluster-pebble:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-cluster-pebble-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=$(DOCKER_USERNAME)/builder-rocksdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-cluster-pebble-$(DOCKER_OS) .

docker-buildx-cropdroid-cluster-rocksdb:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg CLUSTER_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=$(DOCKER_USERNAME)/builder-rocksdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-$(DOCKER_OS) \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-cluster-rocksdb-$(DOCKER_OS) .

docker-buildx-cropdroid-standalone-alpine:
	docker buildx build \
	    --build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg STANDALONE_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-standalone-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-standalone-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-standalone-alpine .

docker-buildx-cropdroid-cluster-pebble-alpine:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg CLUSTER_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-cluster-pebble-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=$(DOCKER_USERNAME)/builder-rocksdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-cluster-pebble-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-alpine .

docker-buildx-cropdroid-cluster-rocksdb-alpine:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_ALPINE_IMAGE) \
		--build-arg CLUSTER_BUILDER=$(DOCKER_USERNAME)/builder-cropdroid-cluster-rocksdb-$(DOCKER_OS) \
		--build-arg ROCKSDB_BUILDER=$(DOCKER_USERNAME)/builder-rocksdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cropdroid-cluster-rocksdb-alpine \
		-f $(DOCKER_HOME)/cropdroid/Dockerfile-cluster-alpine .

docker-buildx-cockroachdb-ubuntu:
	docker buildx build \
		--build-arg CORES=$(CORES) \
		--build-arg BASE_IMAGE=$(DOCKER_IMAGE) \
		--build-arg COCKROACHDB_BUILDER=$(DOCKER_USERNAME)/builder-cockroachdb-$(DOCKER_OS) \
		--platform linux/amd64,linux/arm64 \
		--push \
		-t $(DOCKER_BUILDX_TAG_PREFIX)cockroachdb-$(DOCKER_OS) \
		-f $(DOCKER_HOME)/cockroachdb/Dockerfile-$(DOCKER_OS) .

docker-buildx-builders: docker-buildx-rocksdb \
	docker-buildx-builder-cockroachdb \
	docker-buildx-builder-standalone \
	docker-buildx-builder-cluster

docker-buildx-builder-cluster: docker-buildx-builder-cluster-pebble \
	docker-buildx-builder-cluster-rocksdb

docker-buildx-cropdroid: docker-buildx-cropdroid-standalone \
	docker-buildx-cropdroid-cluster

docker-buildx-cropdroid-cluster: docker-buildx-cropdroid-cluster-pebble \
	docker-buildx-cropdroid-cluster-rocksdb

docker-buildx-cropdroid-alpine: docker-buildx-cropdroid-standalone-alpine \
	docker-buildx-cropdroid-cluster-alpine

docker-buildx-cropdroid-cluster-alpine: docker-buildx-cropdroid-cluster-pebble-alpine \
	docker-buildx-cropdroid-cluster-rocksdb-alpine

docker-buildx-all: docker-buildx-base \
	docker-buildx-builders \
	docker-buildx-cockroachdb-ubuntu \
	docker-buildx-cropdroid	\
	docker-buildx-cropdroid-alpine

docker-images: docker-build-all docker-buildx-all

docker-login:
	docker login $(DOCKER_REGISTRY)



# -------- #
# Minikube #
# -------- #
minikube-start:
	minikube \
		--memory 8192 \
		--cpus $(CORES) \
		--driver=docker \
		--insecure-registry "$(DOCKER_SUBNET)" \
		start
	minikube addons enable registry
	$(MAKE) minikube-registry-port-forward
	minikube dashboard &

minikube-init:
	docker pull $(DOCKER_REGISTRY)$(DOCKER_USERNAME)/

minikube-registry-port-forward:
	NODE_NAME=$(shell kubectl get pods -n kube-system -l actual-registry=true | cut -d ' ' -f1 | tail -n 1) ; \
	kubectl port-forward --namespace kube-system $$NODE_NAME 5000:5000 &

minikube-dev: minikube-start
	direnv reload
	$(MAKE) docker-build-all



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


# k8s-secret-local-registry:
# 	kubectl create secret docker-registry local-registry \
# 		--docker-server=$(DOCKER_REGISTRY) \
# 		--docker-username=$(DOCKER_USERNAME) \
# 		--docker-password=$(DOCKER_PASSWORD) \
# 		--docker-email=$(DOCKER_EMAIL)
# 	#DOCKER_REGISTRY=registry.cropdroid.local DOCKER_USERNAME=admin DOCKER_PASSWORD=secret make k8s-secret-local-registry


k8s-deploy-all: k8s-deploy-cropdroid-standalone \
	k8s-deploy-cluster

k8s-delete-all: k8s-delete-cropdroid-standalone \
	k8s-delete-cluster


k8s-deploy-cluster: k8s-deploy-cockroachdb \
	k8s-deploy-cropdroid-cluster

k8s-delete-cluster: k8s-delete-cockroachdb \
	k8s-delete-cropdroid-cluster


k8s-deploy-cropdroid: k8s-deploy-cropdroid-standalone \
	k8s-deploy-cropdroid-cluster

k8s-delete-cropdroid: k8s-delete-cropdroid-standalone \
	k8s-delete-cropdroid-cluster


k8s-deploy-cropdroid-standalone:
	kubectl apply -k devops/kubernetes/cropdroid-standalone/overlays/$(ENV)

k8s-delete-cropdroid-standalone:
	kubectl delete -k devops/kubernetes/cropdroid-standalone/overlays/$(ENV)

k8s-redeploy-cropdroid-standalone: k8s-delete-cropdroid-standalone \
	k8s-deploy-cropdroid-standalone


k8s-deploy-cropdroid-cluster:
	kubectl apply -k devops/kubernetes/cropdroid-cluster/overlays/$(ENV)

k8s-delete-cropdroid-cluster:
	kubectl delete -k devops/kubernetes/cropdroid-cluster/overlays/$(ENV)

k8s-redeploy-cropdroid-cluster: k8s-delete-cropdroid-cluster \
	k8s-delete-cropdroid-cluster


k8s-deploy-cockroachdb:
	#kubectl create namespace cockroachdb-operator
	kubectl apply -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/crdb.cockroachlabs.com_crdbclusters.yaml
	kubectl apply -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/operator.yaml
	kubectl apply -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/cluster.yaml

	#kubectl apply -k $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/overlays/dev
	#kubectl port-forward service/cockroachdb-public 8080 &

k8s-deploy-cockroachdb-crdb:
	kubectl apply -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/crdb.cockroachlabs.com_crdbclusters.yaml

k8s-delete-cockroachdb-crdb:
	kubectl delete -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/crdb.cockroachlabs.com_crdbclusters.yaml

k8s-delete-cockroachdb:
	kubectl delete -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/crdb.cockroachlabs.com_crdbclusters.yaml
	kubectl delete -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/operator.yaml
	kubectl delete -f $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/base/cluster.yaml

	#kubectl delete -k $(DEVOPS_HOME)/kubernetes/cockroachdb-operator/overlays/dev
	#kubectl delete namespace cockroachdb-operator

	$(MAKE) k8s-delete-cockroachdb-pvc

k8s-delete-cockroachdb-pvc:
	kubectl delete pvc datadir-cockroachdb-0
	kubectl delete pvc datadir-cockroachdb-1
	kubectl delete pvc datadir-cockroachdb-2

k8s-redeploy-cockroachdb: k8s-delete-cockroachdb \
	k8s-deploy-cockroachdb


k8s-port-forward-cockroachdb:
	kubectl port-forward service/cockroachdb-public 8080

k8s-clean:
	-kubectl delete pvc --all
	-kubectl delete pv --all



k3s-set-context:
	kubectl config set-context cropdroid-1

k3s-deploy-cropdroid: k3s-set-context \
	k8s-deploy-cockroachdb-crdb
	kubectl apply -k $(DEVOPS_HOME)/kubernetes/cropdroid-cluster/overlays/raspi

k3s-delete-cropdroid: k3s-set-context
#	k8s-delete-cockroachdb-pvc
	kubectl delete -k $(DEVOPS_HOME)/kubernetes/cropdroid-cluster/overlays/raspi



# cockroach-sql:
# 	kubectl exec -it cockroachdb-2 -- ./cockroach sql --certs-dir cockroach-certs

# cockroach-admin-setup:
# 	CREATE USER root WITH PASSWORD 'cropdroid';



# ---------#
# Skaffold #
# ---------#
skaffold-dev: k8s-deploy-cockroachdb-crdb
    # skaffold isnt deploying cockroach crdb ... bug¿
	# working around with k8s-deploy-cockroachdb-crdb for now
	skaffold dev

skaffold-cleanup:
	killall skaffold
	$(MAKE) k8s-delete-cockroachdb-pvc



# --------------- #
# SD Card Imaging #
# --------------- #
sdcard:
	$(shell bash -c 'read -s -p "Writing image $(RPI_IMAGE_ARTIFACT) to $(RPI_SDCARD). Press any key to continue or CTRL+C to abort!"')
	-sudo -E umount /media/$(USER)/rootfs
	-sudo -E umount /media/$(USER)/boot
	sudo dd bs=4M if=$(RPI_IMAGE_ARTIFACT) of=$(RPI_SDCARD) conv=fsync

sdcard-standalone-raspios64: ansible-artifacts-common ansible-artifact-standalone-arm64
	IMAGE_NAME=$(HOSTNAME)-standalone-raspios64 \
	$(MAKE) packer-raspios64 sdcard

sdcard-cluster-pebble-raspios64: ansible-artifacts-common ansible-artifact-standalone-arm64
	IMAGE_NAME=$(HOSTNAME)-cluster-pebble-raspios64 \
	APPTYPE=cluster \
	$(MAKE) packer-raspios64 sdcard

# Packer build not working :(
# sdcard-standalone-ubuntu: ansible-artifacts-common ansible-artifact-standalone-arm64
# 	IMAGE_NAME=$(APP)-standalone-raspios64 \
# 	$(MAKE) packer-ubuntu64 sdcard



# ------ #
# Packer #
# ------ #
packer:
	PACKER_FILE=$(PACKER_BUILDER).json \
	$(MAKE) packer-build

packer-build:
	@echo "PACKER_BUILDER: $(PACKER_BUILDER)"
	@echo "RPI_IMAGE_ARTIFACT: $(RPI_IMAGE_ARTIFACT)"
	cd $(DEVOPS_HOME) && sudo -E packer build \
		-var "aws_access_key_id=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "aws_region=${AWS_REGION}" \
		-var "aws_profile=${AWS_PROFILE}" \
		-var "local_user=$(USER)" \
		-var "appname=$(APP)" \
		-var "apptype=$(APPTYPE)" \
		-var "appenv=$(ENV)" \
		-var "timezone=$(TIMEZONE)" \
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
		-var "cockroachdb_user=$(TARGET_USER) \
		-var "cockroachdb_owner=$(TARGET_USER) \
		-var "datastore=$(CROPDROID_DATASTORE)" \
		-var "cropdroid_binary=cropdroid-$(APPTYPE)-arm64" \
	    packer/$(PACKER_FILE)
	sudo -E cp $(DEVOPS_HOME)/output-$(PACKER_BUILDER)/image $(RPI_IMAGE_ARTIFACT)
	sudo chown $(USER) $(RPI_IMAGE_ARTIFACT)

packer-ubuntu64: ansible-artifacts-common ansible-artifact-standalone-arm64
	PACKER_BUILDER=$(PACKER_BUILDER_UBUNTU64) \
	$(MAKE) packer

packer-raspios64: ansible-artifacts-common ansible-artifact-standalone-arm64
	PACKER_BUILDER=$(PACKER_BUILDER_RASPIOS64) \
	$(MAKE) packer

packer-clean:
	sudo rm -rf $(DEVOPS_HOME)/output-* && \
	rm -rf $(DEVOPS_HOME)/images/*



# ------- #
# Ansible #
# ------- #
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
		-e hostname=$(HOSTNAME) \
		-e cropdroid_home=$(DEPLOY_HOME) \
		-e cropdroid_binary=cropdroid-$(APPTYPE)-arm64 \
		-e wlan_ssid=$(WLAN_SSID) \
		-e wlan_psk=$(WLAN_PSK) \
		-e wlan_key_mgmt=$(WLAN_KEY_MGMT) \
		-e wlan_country=$(WLAN_COUNTRY) \
		-e datastore=$(CROPDROID_DATASTORE) \
		-e "gossip_peers=$(CLUSTER_GOSSIP_PEERS)" \
		-e "raft_peers=$(CLUSTER_RAFT_PEERS)" \
		-e "cockroachdb_user=$(TARGET_USER) \
		-e "cockroachdb_owner=$(TARGET_USER) \
		-e "cockroachdb_peers=$(COCKROACHDB_JOIN_FLAG)" \
		-e owner=$(WEBSERVER_USER) \
		-e group=$(TARGET_USER)

ansible-rsync:
	rsync -avr -e "ssh -l $(TARGET_USER)" $(DEVOPS_HOME)/ansible/* $(TARGET_USER)@$(TARGET_HOST):ansible

ansible-artifacts-common: ansible-firmware
	cd $(CROPDROID_SRC) && \
		cp -R keys/ $(ANSIBLE_CROPDROID_FILES)/ && \
		cp -R public_html/ $(ANSIBLE_CROPDROID_FILES)/

ansible-artifact-standalone-x86_64:
	cd $(CROPDROID_SRC) && \
		make -j$(CORES) clean build-standalone && \
		cp cropdroid $(ANSIBLE_CROPDROID_FILES)/cropdroid-standalone-x86_64

ansible-artifact-standalone-arm64:
	cd $(CROPDROID_SRC) && \
		make -j$(CORES) clean build-standalone-arm64-static && \
		cp cropdroid $(ANSIBLE_CROPDROID_FILES)/cropdroid-standalone-arm64

ansible-artifact-standalone-arm:
	cd $(CROPDROID_SRC) && \
		make -j$(CORES) clean build-standalone-arm-static && \
		cp cropdroid $(ANSIBLE_CROPDROID_FILES)/cropdroid-standalone-arm

ansible-artifacts: ansible-artifacts-common \
	ansible-artifact-standalone-x86_64 \
	ansible-artifact-standalone-arm64 \
	ansible-artifact-standalone-arm
#	$(MAKE) ansible-clean

ansible-firmware:
	rm -rf $(ANSIBLE_FIRMWARE)/*.hex
	cp $(FIRMWARE_HOME)/cropdroid-reservoir/build/Mega/cropdroid-reservoir.hex $(ANSIBLE_FIRMWARE)/
	cp $(FIRMWARE_HOME)/cropdroid-room/build/Nano/cropdroid-room.hex $(ANSIBLE_FIRMWARE)/
	cp $(FIRMWARE_HOME)/cropdroid-doser/build/Nano/cropdroid-doser.hex $(ANSIBLE_FIRMWARE)/
	cp $(FIRMWARE_HOME)/cropdroid-irrigation/build/Nano/cropdroid-irrigation.hex $(ANSIBLE_FIRMWARE)/

ansible-cluster:
	CROPDROID_DATASTORE=cockroach APPTYPE=cluster TARGET_USER=ubuntu TARGET_HOST=$(CLUSTER_PEER1) make ansible
	CROPDROID_DATASTORE=cockroach APPTYPE=cluster TARGET_USER=ubuntu TARGET_HOST=$(CLUSTER_PEER2) make ansible
	CROPDROID_DATASTORE=cockroach APPTYPE=cluster TARGET_USER=ubuntu TARGET_HOST=$(CLUSTER_PEER3) make ansible

ansible-public-html:
	cp -R $(CROPDROID_SRC)/public_html $(ANSIBLE_CROPDROID_FILES)

ansible-keys:
	cp -R $(CROPDROID_SRC)/keys $(ANSIBLE_CROPDROID_FILES)

# ansible-clean:
# 	rm -rf $(ANSIBLE_CROPDROID_FILES)/*



# ---------- #
# Qemu / KVM #
# ---------- #
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

qemu-raspios64:
	#-hda $(IMAGES_HOME)/2020-05-27-raspios-buster-arm64-test.img
	#root=LABEL=root ro rootwait console=ttyS1,115200
	#-cpu cortex-a72
	#-kernel $(SOURCES)/rpi4kernel/linux/kernel-build/arch/arm64/boot/Image
	#-net user,hostfwd=tcp::5022-:22
	#-serial stdio
	#-append 'rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0 rootwait memtest=1 panic=1'
	#-drive file=$(IMAGES_HOME)/$(IMAGE_NAME)-qemu.img,format=raw,if=sd \
	#-append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0 rootwait memtest=1" \
	#-no-reboot
	#-cpu cortex-a53 \
	#-device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22 \
	#-append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
	#-drive file=$(IMAGES_HOME)/$(IMAGE_NAME).img,format=raw,if=sd,id=hd-root  \
	##-append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
	#-dtb /home/jhahn/sources/rpi4kernel/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2710-rpi-3-b-plus.dtb \
	#-M raspi3 \
	#-device virtio-blk-device,drive=hd-root \
	#	-netdev user,id=net0,hostfwd=tcp::5022-:22 \
	#	-device virtio-net-device,netdev=net0 \
	sudo qemu-system-aarch64 \
		-kernel /home/jhahn/sources/rpi4kernel/kernel8.img \
		-dtb $(RPI_KERNEL)/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2837-rpi-3-b-plus.dtb \
		-cpu cortex-a53 \
		-M raspi3 \
		-m 1024 \
		-drive file=$(IMAGES_HOME)/$(PACKER_BUILDER).img,format=raw,if=sd,id=hd-root  \
		-append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0 rootwait memtest=1" \
		-nographic


#-kernel /home/jhahn/sources/rpi4kernel/kernel8.img
#-dtb /home/jhahn/sources/rpi4kernel/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb
qemu-arm64:
	#-drive file=devops/output-2020-05-27-raspios-buster-arm64-dev/base-new,if=none,id=drive0,cache=writeback
	qemu-system-aarch64 \
		-nographic \
		-machine raspi3 \
		-m 1024 \
		-cpu cortex-a53 \
		-kernel /home/jhahn/sources/rpi4kernel/kernel8.img \
		-dtb /home/jhahn/sources/rpi4kernel/linux/kernel-build/arch/arm64/boot/dts/broadcom/bcm2837-rpi-3-b-plus.dtb \
		-hda $(IMAGES_HOME)/2021-05-07-raspios-buster-armhf-lite.img
		-netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 \
		-device virtio-net-pci,netdev=vnet \
		-no-reboot

#qemu-system-aarch64 -machine type=raspi3 -m 1024 -kernel vmlinux -initrd initramfs
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
		-drive format=raw,file=$(DEVOPS_HOME)/output-docker-ubuntu-20.04.01-arm64/image,if=none,id=drv0 \
		-device virtio-blk-device,drive=drv0 \
		-no-reboot


qemu-cluster:
	$(SCRIPTS_HOME)/qemu-cluster.sh

# qemu:
# 	qemu-system-arm \
# 		-M versatilepb \
# 		-cpu arm1176 \
# 		-m 256 \
# 		-hda $(RPI_IMAGE_ARTIFACT) \
# 		-net user,hostfwd=tcp::5022-:22 \
# 		-dtb $(RPI_KERNEL)/versatile-pb.dtb \
# 		-kernel $(RPI_KERNEL)/kernel-qemu-4.14.79-stretch \
# 		-append "root=/dev/sda2 panic=1" \
# 		-no-reboot

# output-docker-ubuntu-20.04.01-arm64
# -drive "file=${iso},id=cdrom,if=none,media=cdrom"
# -drive "if=none,file=${img_snapshot},id=hd0"
qemu-ubuntu-test:
	qemu-system-aarch64 \
		-machine type=raspi3 \
		-m 1024 \
		-kernel vmlinux \
		-initrd initramfs


# qemu-system-aarch64 \
# -cpu cortex-a57 \
# -device rtl8139,netdev=net0 \
# -device virtio-scsi-device \
# -device scsi-cd,drive=cdrom \
# -device virtio-blk-device,drive=hd0 \
# -drive "file=${IMAGES_HOME}/ubuntu-20.04.2-live-server-arm64.iso,id=cdrom,if=none,media=cdrom" \
# -drive "if=none,file=${IMAGES_HOME}/qemu-ubuntu-test.img,id=hd0" \
# -m 2G \
# -machine virt \
# -netdev user,id=net0 \
# -nographic \
# -pflash "$(IMAGES_HOME)/flash0.img" \
# -pflash "$(IMAGES_HOME)/flash1.img" \
# -smp 2 \





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

docker-run-init:
	#-v "${PWD}/cropdroid-data/cropdroid-0-0:/cropdroid-data"
	#-v "${PWD}/keys:/keys"
	docker run -d \
		--name=cropdroid-init \
		--hostname=cropdroid-init \
		--net=cropnet \
		-p 8091:8091 \
		$(CROPDROID_SRC)/cropdroid config --init --debug --datastore cockroach --datastore-host roach1

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
	#docker exec -it roach1 ./cockroach init --insecure
	#./$(APP) config --init --datastore cockroach
	#docker exec -it roach1 ./cockroach sql --insecure

docker-run-cropdroid-cluster-pebble:
	#-v "${PWD}/cropdroid-data/cropdroid-0-0:/cropdroid-data"
	#-v "${PWD}/keys:/keys"

	docker run -d \
		--name=cropdroid-0-0 \
		--hostname=cropdroid-0-0 \
		--ip $(DOCKER_NODE1_IP) \
		--net=cropnet \
		-p 8091:8091 \
		$(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-pebble-$(DOCKER_OS) $(DEPLOY_HOME)/cropdroid cluster \
			--debug \
			--ssl=false \
			--port 8091 \
			--datastore cockroach \
			--datastore-host roach1 \
			--enable-registrations \
			--listen $(DOCKER_NODE1_IP) \
			--raft "$(DOCKER_NODE1_IP):60020,$(DOCKER_NODE2_IP):60021,$(DOCKER_NODE3_IP):60022"
	docker run -d \
		--name=cropdroid-0-1 \
		--hostname=cropdroid-0-1 \
		--ip $(DOCKER_NODE2_IP) \
		--net=cropnet \
		-p 8092:8092 \
		$(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-pebble-$(DOCKER_OS) $(DEPLOY_HOME)/cropdroid cluster \
			--debug \
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
		--name=cropdroid-0-2 \
		--hostname=cropdroid-0-2 \
		--ip $(DOCKER_NODE3_IP) \
		--net=cropnet \
		-p 8093:8093 \
		$(DOCKER_BUILD_TAG_PREFIX)cropdroid-cluster-pebble-$(DOCKER_OS) $(DEPLOY_HOME)/cropdroid cluster \
			--debug \
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
	$(SCRIPTS_HOME)/docker-cluster-tmux.sh

docker-run-cluster-pebble:
	cd $(CROPDROID_SRC) && \
		make build-cluster-pebble-debug-static
	$(MAKE) docker-build-base \
		docker-build-builder-cropdroid-cluster-pebble \
		docker-build-cropdroid-cluster-pebble
	$(MAKE) docker-run-cockroachdb-cluster \
		docker-run-cropdroid-cluster-pebble

docker-run-cropdroid-standalone:
	docker run -d \
		--name=cropdroid-standalone \
		--hostname=cropdroid \
		--ip $(DOCKER_NODE1_IP) \
		--net=cropnet \
		-p 8091:8091 \
		-v "${PWD}/cropdroid-data/cropdroid:/cropdroid-data" \
		-v "${PWD}/keys:/keys" \
		$(DOCKER_BUILD_TAG_PREFIX)cropdroid-standalone-$(DOCKER_OS) $(DEPLOY_HOME)/$(APP) standalone \
			--debug \
			--data-dir /cropdroid-data \
			--log-dir / \
			--log-file /cropdroid.log \
			--keys /keys \
			--ssl=false \
			--port 8091 \
			--enable-registrations

docker-run-cropdroid-cluster-clean:
	- docker stop cropdroid-0-0 cropdroid-0-1 cropdroid-0-2
	- docker rm -f cropdroid-0-0 cropdroid-0-1 cropdroid-0-2
	- docker stop roach1 roach2 roach3
	- docker rm -f roach1 roach2 roach3
	- tmux kill-server

docker-cockroachdb-log:
	docker logs roach1

docker-cockroachdb-clean:
	docker stop roach1 roach2 roach3
	docker rm roach1 roach2 roach3
	sudo rm -rf db/cockroach-data/*



# https://blog.tekspace.io/deploying-kubernetes-dashboard-in-k3s-cluster/
k3s-dashbaord:
	ssh $(TARGET_USER)@$(TARGET_HOST) sudo k3s kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
	$(BROWSER) https://$(TARGET_HOST):32637/#/overview?namespace=default



# ------------------------ #
# Local development system #
# ------------------------ #
local-init-log:
	sudo touch /var/log/cropdroid.log && sudo chmod 777 /var/log/cropdroid.log
	sudo mkdir -p /var/log/cropdroid/cluster
	sudo touch /var/log/cropdroid/cluster/node-1.log && sudo chmod 777 /var/log/cropdroid/cluster/node-1.log
	sudo touch /var/log/cropdroid/cluster/node-2.log && sudo chmod 777 /var/log/cropdroid/cluster/node-2.log
	sudo touch /var/log/cropdroid/cluster/node-3.log && sudo chmod 777 /var/log/cropdroid/cluster/node-3.log
	sudo chown -R $(USER) /var/log/cropdroid

local-init-standalone:
	cd $(CROPDROID_SRC) && make build-standalone-debug
	mkdir db

# local-init-cluster:
# 	set -e ; \
# 	FILES="/var/log/$(APP)-1.log /var/log/$(APP)-2.log /var/log/$(APP)-3.log" ; \
# 	sudo touch $$FILES ; \
# 	sudo chown $(USER) $$FILES

local-cockroach-init:
	$(CROPDROID_SRC)/cropdroid config \
		--init \
		--debug \
		--enable-default-farm=false \
		--datastore cockroach

local-cluster-cockroach:
	$(SCRIPTS_HOME)/start-cockroach-cluster.sh

local-cockroach-cluster:
	$(SCRIPTS_HOME)/start-cockroach-cluster.sh

local-roach: local-cropdroid-cluster-compile \
	local-cockroach-cluster \
	local-cockroach-init

local-cropdroid-cluster-compile:
	cd $(CROPDROID_SRC) && \
		make build-cluster-pebble-debug

local-cropdroid-copy:
	cp $(CROPDROID_SRC)/$(APP) .

local-cropdroid-cluster-pebble: local-cockroach-init \
	local-cropdroid-cluster-compile

	cp -R $(CROPDROID_SRC)/public_html .
	cp -R $(CROPDROID_SRC)/keys .
	$(SCRIPTS_HOME)/start-cluster-debug.sh
	#$(SCRIPTS_HOME)/start-cluster-tmux.sh

local-cropdroid-cluster-debug: build-cluster-pebble-debug
# 	$(SCRIPTS_HOME)/start-cluster-tmux.sh

# local-cluster-debug: local-clean \
# 	local-cockroach-cluster \
# 	local-cropdroid-cluster-pebble

local-cluster-debug: local-clean \
	local-cropdroid-cluster-compile \
	local-cropdroid-copy \
	local-keys-and-public-html

	#$(MAKE) -f $(CROPDROID_SRC)/Makefile certs
	$(SCRIPTS_HOME)/start-cluster-debug.sh

local-sqlite-init:
	mkdir db
	$(CROPDROID_SRC)/$(APP) config --debug --init --datastore sqlite

local-keys-and-public-html:
	mkdir keys/ && cp -R $(CROPDROID_SRC)/keys .
	cp -R $(CROPDROID_SRC)/public_html .

local-standalone: local-keys-and-public-html
	cd $(CROPDROID_SRC) && make build-standalone-debug
	$(CROPDROID_SRC)/$(APP) standalone --debug --init --ssl=false --port 8091

local-standalone-memory: local-clean \
	local-init-log \
	local-keys-and-public-html \
	local-init-standalone

	$(CROPDROID_SRC)/$(APP) standalone --debug --ssl=false --port 8091

local-standalone-sqlite: local-clean \
	local-init-log \
	local-keys-and-public-html \
	local-init-standalone

	$(CROPDROID_SRC)/$(APP) standalone --debug --ssl=false --port 8091 --datastore sqlite

local-standalone-sqlite-with-farm: local-clean \
	local-init-log \
	local-keys-and-public-html \
	local-init-standalone

	$(CROPDROID_SRC)/$(APP) standalone --debug --init --ssl=false --port 8091 --datastore sqlite --enable-default-farm=true

local-standalone-cockroach:
	cd $(CROPDROID_SRC) && make build-standalone-debug
	$(CROPDROID_SRC)/$(APP) standalone --debug --ssl=false --port 8091 --datastore cockroach

local-clean:
	-killall -9 cockroach
	-killall -9 $(APP)*
	-tmux kill-server
	-rm -rf db/
	-rm -rf keys/
	-rm -rf public_html/
	-rm -rf example-data/
	-rm -rf pebbledb-data/
	-rm -rf $(CROPDROID_SRC)/db/
	-rm -rf $(CROPDROID_SRC)/example-data/
	-rm -rf $(CROPDROID_SRC)/pebbledb-data/
	-sudo rm -rf /var/log/cropdroid*
	-rm -rf $(CROPDROID_SRC)/db/cluster/*

local-redeploy-cropdroid-cluster-pebble: local-clean \
	local-cropdroid-cluster-pebble
	#killall cockroach
	#killall $(APP)*
	#tmux kill-server
	#rm -rf db/
	#$(MAKE) local-cropdroid-cluster-pebble

local-pebblels-debug:
	mkdir -p db/cluster/tmp$(PEBBLE_CLUSTER_ID)/
	cp -R $(CROPDROID_SRC)/db/cluster/$(PEBBLE_CLUSTER_ID)_3/*/* db/cluster/tmp$(PEBBLE_CLUSTER_ID)
	$(CROPDROID_SRC)/cropdroid pebble \
		--data-dir db/cluster/tmp$(PEBBLE_CLUSTER_ID) ls
	rm -rf db/cluster/tmp$(PEBBLE_CLUSTER_ID)

local-pebblels:
	mkdir -p db/cluster/tmp$(PEBBLE_CLUSTER_ID)/
	cp -R db/cluster/$(PEBBLE_CLUSTER_ID)_1/*/* db/cluster/tmp$(PEBBLE_CLUSTER_ID)
	$(CROPDROID_SRC)/cropdroid pebble \
		--data-dir db/cluster/tmp$(PEBBLE_CLUSTER_ID) ls
	rm -rf db/cluster/tmp$(PEBBLE_CLUSTER_ID)

local-pebblels-testdata:
	-rm -rf $(CROPDROID_SRC)/datastore/raft/test-data/tmp$(PEBBLE_CLUSTER_ID)
	mkdir $(CROPDROID_SRC)/datastore/raft/test-data/tmp$(PEBBLE_CLUSTER_ID)/
	cp -R $(CROPDROID_SRC)/datastore/raft/test-data/$(PEBBLE_CLUSTER_ID)_1/*/* $(CROPDROID_SRC)/datastore/raft/test-data/tmp$(PEBBLE_CLUSTER_ID)
	$(CROPDROID_SRC)/cropdroid pebble \
		--data-dir $(CROPDROID_SRC)/datastore/raft/test-data/tmp$(PEBBLE_CLUSTER_ID) ls
	rm -rf $(CROPDROID_SRC)/datastore/raft/test-data/tmp$(PEBBLE_CLUSTER_ID)

# Apache Bench Performance Testing
ab-system:
	ab -n 1000 -c $(CORES) $(API_SYSTEM_ENDPOINT)

ab-farm-state:
	ab -n 1000 -c $(CORES) -H "Authorization: $(API_JWT_TOKEN)" $(API_STATE_ENDPOINT)

ab-farm-config:
	ab -n 1000 -c $(CORES) -H "Authorization: $(API_JWT_TOKEN)" $(API_CONFIG_ENDPOINT)

ab-farm-devices:
	ab -n 1000 -c $(CORES) -H "Authorization: $(API_JWT_TOKEN)" $(API_DEVICES_ENDPOINT)

ab-all: ab-system \
	ab-farm-state \
	ab-farm-config \
	ab-farm-devices



# Websocket Test
websocket-test:
	@echo '{\"id\":\"$(API_UID)\"}'
	$(GOBIN)/ws $(API_FARMTICKER_ENDPOINT)

#	curl -vvv --include \
#      --no-buffer \
#      --header "Connection: Upgrade" \
#      --header "Upgrade: websocket" \
#      --header "Host: $(LOCAL_ADDRESS)" \
#      --header "Origin: $(API_ENDPOINT)" \
#	  --header "Authorization: $(API_JWT_TOKEN)" \
#      --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
#      --header "Sec-WebSocket-Version: 13" \
#      $(API_FARMTICKER_ENDPOINT)

rest-provision:
	curl -s -X POST \
    	-d '{"username": "admin"}' \
     	--header "Host: $(LOCAL_ADDRESS)" \
     	--header "Origin: $(API_ENDPOINT)" \
	 	--header "Authorization: $(API_JWT_TOKEN)" \
     	$(API_PROVISIONER_ENDPOINT) | jq .

rest-login:
	curl -s -X POST \
    	-d '{"email": "$(API_USERNAME)", "password": "$(API_PASSWORD)", "authType": $(API_AUTH_TYPE)}' \
     	--header "Host: $(LOCAL_ADDRESS)" \
     	--header "Origin: $(API_ENDPOINT)" \
     	$(API_LOGIN_ENDPOINT) | jq .

rest-login-refresh:
	curl -s -X GET \
     	--header "Host: $(LOCAL_ADDRESS)" \
     	--header "Origin: $(API_ENDPOINT)" \
		--header "Authorization: $(API_JWT_TOKEN)" \
     	$(API_LOGIN_REFRESH_ENDPOINT)
