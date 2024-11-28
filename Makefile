SETUP = ./tf/scripts/set-vars.sh
TIMESTAMP = $(sh date +%y.%m.%d-%H.%M.%S)

.PHONY = tfi tfp tfa tfd tfre tfpr tfrc tfiu db drb drun dt dp

# terraform plan
tfp: 
	@echo "Running Terraform plan..."
	@. $(SETUP) && cd tf && env | grep TF_VAR && terraform plan \
		-backend-config="region=$$TF_VAR_AWS_REGION" \
		-backend-config="bucket=$$AWS_STATE_BUCKET" \
		-backend-config="key=$$AWS_STATE_KEY_PATH"

# terraform apply
tfa:
	@$(START) && \
	cd tf && \
	terraform apply

# terraform init
tfi: 
	@echo "Running Terraform init..."
	@. $(SETUP) && cd tf && env | grep TF_VAR && terraform init \
		-backend-config="region=$$TF_VAR_AWS_REGION" \
		-backend-config="bucket=$$AWS_STATE_BUCKET" \
		-backend-config="key=$$AWS_STATE_KEY_PATH"

# terraform init reconfigure
tfir: 
	@echo "Running Terraform init..."
	@. $(SETUP) && cd tf && env | grep TF_VAR && terraform init -reconfigure \
		-backend-config="region=$$TF_VAR_AWS_REGION" \
		-backend-config="bucket=$$AWS_STATE_BUCKET" \
		-backend-config="key=$$AWS_STATE_KEY_PATH"

# terraform init upgrade
tfiu:
	@$(START) && \
	cd tf && \
	terraform init -upgrade

# terraform refresh
tfre:
	@$(START) && \
	cd tf && \
	terraform refresh

# terraform destroy
tfd:
	@$(START) && \
	cd tf && \
	terraform destroy

# docker build
db:
	@cd server && \
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) .

# docker rebuild (nocache)
drb:
	@cd server && \
	docker buildx build --platform linux/amd64 --no-cache -t $(IMAGE_NAME) .

# docker run
drun:
	@cd server && \
	docker run -p 443:8000 -t $(IMAGE_NAME) .

# docker tag
dt:
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(TIMESTAMP)
	@docker tag $(IMAGE_NAME):latest $(ECR_URI):latest

# docker push
dp:
	@cd server && \
	aws ecr get-login-password --region $(TF_VAR_AWS_REGION) | docker login --username AWS --password-stdin $(ECR_URI)
	@make dt
	@docker push $(ECR_URI)
