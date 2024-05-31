VERSION=1.24.0
# ~dev-103-g1ef9b1b
IMG_NAME=openmodelica/openmodelica:v$(VERSION)

BUILDCOMMAND=docker build --platform linux/amd64

build:
	# @echo "Use target upload instead; --load does not work in current docker"
	# @false
	$(BUILDCOMMAND) --load --build-arg VERSION=$(VERSION) -t openmodelica/openmodelica:v$(VERSION)-minimal - < Dockerfile
	$(BUILDCOMMAND) --load --build-arg BASE=openmodelica/openmodelica:v$(VERSION)-minimal -t openmodelica/openmodelica:v$(VERSION)-ompython - < Dockerfile.ompython
	$(BUILDCOMMAND) --load --build-arg BASE=openmodelica/openmodelica:v$(VERSION)-ompython -t openmodelica/openmodelica:v$(VERSION)-gui - < Dockerfile.gui

bootstrap:
	docker pull tonistiigi/binfmt:latest
	docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx use complex-builder || docker buildx create --name complex-builder --driver docker-container --bootstrap --use
	docker buildx ls

upload:
	$(BUILDCOMMAND) --build-arg VERSION=$(VERSION) -t openmodelica/openmodelica:v$(VERSION)-minimal --push - < Dockerfile
	$(BUILDCOMMAND) --build-arg BASE=openmodelica/openmodelica:v$(VERSION)-minimal -t openmodelica/openmodelica:v$(VERSION)-ompython --push - < Dockerfile.ompython
	$(BUILDCOMMAND) --build-arg BASE=openmodelica/openmodelica:v$(VERSION)-ompython -t openmodelica/openmodelica:v$(VERSION)-gui --push - < Dockerfile.gui

run-gui:
	docker run \
		--platform=linux/amd64 \
		--name $(IMG_NAME) \
		--detach=true \
		--network=host \
		--rm \
		--user $(UID) \
		-it \
		-v $(HOME):$(HOME) \
		-w $(PWD) \
		-e $(HOME):$(HOME) \
		-e DISPLAY=`ifconfig | grep -o "inet [0-9.]*" | grep -Eo "[0-9.]{7,}" | grep -Fv 127.0.0.1 | head -1`:0 \
		$(IMG_NAME)-gui