export VERSION ?= 0.1~dev

VARIANTS := $(patsubst configs/%,%,$(wildcard configs/*-*-*))

all: \
	$(patsubst %,%-$(VERSION)-armhf.tar.xz,$(VARIANTS)) \
	$(patsubst %,%-$(VERSION)-arm64.tar.xz,$(VARIANTS))

info:
	@echo $(VARIANTS)

%.xz: %
	pxz -f -3 $<

%.tar:
	eatmydata -- bash build.sh "$@" \
		"$(shell basename "$@" -$(VERSION)-$(BUILD_ARCH).tar)" \
		"$(BUILD_MODE)" \
		"$(BUILD_SUITE)" \
		"$(BUILD_ARCH)"

%-armhf.tar.xz: BUILD_ARCH=armhf
%-arm64.tar.xz: BUILD_ARCH=arm64

$(addsuffix -armhf, $(VARIANTS)): %-armhf: %-$(VERSION)-armhf.tar.xz
$(addsuffix -arm64, $(VARIANTS)): %-arm64: %-$(VERSION)-arm64.tar.xz

ubuntu-%.tar.xz: BUILD_MODE=ubuntu
ubuntu-bionic-%.tar.xz: BUILD_SUITE=bionic
ubuntu-xenial-%.tar.xz: BUILD_SUITE=xenial
ubuntu-disco-%.tar.xz: BUILD_SUITE=disco

debian-%.tar.xz: BUILD_MODE=debian
debian-stretch-%.tar.xz: BUILD_SUITE=stretch
debian-buster-%.tar.xz: BUILD_SUITE=buster

.PHONY: shell		# run docker shell to build image
shell:
	@echo Building environment...
	@docker build -q -t rock64-rootfs:build-environment environment/
	@echo Entering shell...
	@docker run --rm \
		-it \
		-e HOME -v $(HOME):$(HOME) \
		--privileged \
		-h rock64-build-env \
		-v $(CURDIR):$(CURDIR) \
		-w $(CURDIR) \
		rock64-rootfs:build-environment
