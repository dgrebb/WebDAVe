START = source ./tf/scripts/set-tf-vars.sh
IMAGE_NAME = $(shell pass webdav/image-name)
ECR_URI = $(shell pass webdav/ecr-uri)
REGION = $(shell pass aws/region)
TIMESTAMP = $(shell date +%y.%m.%d-%H.%M.%S)

.PHONY = tfi tfp tfa tfd tfre tfpr tfrc tfiu db drb drun dt dp

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

dt:
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(TIMESTAMP)
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):latest

dp:
	@cd server && \
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URI)
	@make dt
	@docker push $(ECR_URI)