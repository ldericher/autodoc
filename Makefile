image_tag = ldericher/autodoc
docker_build = docker build
docker_run = docker run --rm -it
examples_flags = -v "$(shell pwd)/examples:/docs" -u "$(shell id -u):$(shell id -g)"

.PHONY: default
default:
	$(info use other targets: image build watch shell clean)

.PHONY: image
image:
	$(docker_build) --tag $(image_tag) ./

.PHONY: build
build: image
	$(docker_run) $(examples_flags) $(image_tag) -b

.PHONY: watch
watch: image
	$(docker_run) $(examples_flags) $(image_tag)

.PHONY: shell
shell: image
	$(docker_run) $(examples_flags) --entrypoint ash $(image_tag)

.PHONY: clean
clean:
	git clean -xdf ./examples