IMAGE=cloudposse/terraform-generator

docker/build:
	docker build --target run -t $(IMAGE):latest .
	docker build --target local_run -t $(IMAGE):run .
	docker build --target test -t $(IMAGE):test-latest .

test:
	docker run --rm $(IMAGE):test-latest

shell:
	docker run -it --rm $(IMAGE):run