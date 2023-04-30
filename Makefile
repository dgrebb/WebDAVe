START = source ./tf/scripts/set-tf-vars.sh
IMAGE_NAME = $(shell pass webdav/image-name)
ECR_URI = $(shell pass webdav/ecr-uri)
REGION = $(shell pass aws/region)

.PHONY = tfi tfp tfa tfd tfre tfpr tfrc tfiu db drb drun drt dp dt

tfi:
	@$(START) && \
	cd tf && \
	terraform init

tfiu:
	@$(START) && \
	cd tf && \
	terraform init -upgrade

tfp:
	@$(START) && \
	cd tf && \
	terraform plan

tfa:
	@$(START) && \
	cd tf && \
	terraform apply

tfre:
	@$(START) && \
	cd tf && \
	terraform refresh

tfpr:
	@$(START) && \
	cd tf && \
	terraform apply -target=aws_ecr_repository.webdav_image_repo

tfrc:
	@$(START) && \
	cd tf && \
	terraform apply -replace=aws_ecs_task_definition.webdav

tfd:
	@$(START) && \
	cd tf && \
	terraform destroy

db:
	@cd server && \
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) .

drb:
	@cd server && \
	docker buildx build --platform linux/amd64 --no-cache -t $(IMAGE_NAME) .

drun:
	@cd server && \
	docker run -p 443:8000 -t $(IMAGE_NAME) .

da:
	@cd server && \
	docker tag $(ECR_URI):latest $(ECR_URI):last

dp:
	@cd server && \
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URI)
	@docker tag $(ECR_URI):latest $(ECR_URI):last
	@docker tag $(IMAGE_NAME):latest $(ECR_URI):latest
	@docker push $(ECR_URI)