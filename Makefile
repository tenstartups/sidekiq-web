DOCKER_IMAGE_NAME := tenstartups/sidekiq-web:latest

PLATFORMS ?= linux/amd64,linux/arm64

build: Dockerfile
	docker build --file Dockerfile --tag $(DOCKER_IMAGE_NAME) .

clean_build: Dockerfile
	docker build --no-cache --pull --file Dockerfile --tag $(DOCKER_IMAGE_NAME) .

run: build
	docker run -it --rm -e APP_ENV=production -p 9292:9292 $(DOCKER_IMAGE_NAME) $(ARGS)

push: Dockerfile
	docker buildx build --platform $(PLATFORMS) --file Dockerfile --tag $(DOCKER_IMAGE_NAME) --push .
