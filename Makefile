SETUP = ./tf/scripts/set-vars.sh
TIMESTAMP = $(shell date +%y.%m.%d-%H.%M.%S)
TF_BACKEND_CONFIG = -backend-config="region=$$TF_VAR_AWS_REGION" \
                    -backend-config="bucket=$$AWS_STATE_BUCKET" \
                    -backend-config="key=$$AWS_STATE_KEY_PATH"
DOCKER_PLATFORM = --platform linux/amd64

.PHONY: tfi tfp tfa tfd tfre tfpr tfrc tfiu db drb drun dt dp

# General Terraform command template
define tf_command
	@echo "Running Terraform $1..."
	@. $(SETUP) && cd tf && terraform $1 $(2)
endef

# Terraform commands
tfp:
	$(call tf_command,plan)

tfa:
	$(call tf_command,apply)

tfi:
	$(call tf_command,init,$(TF_BACKEND_CONFIG))

tfir:
	$(call tf_command,init,-reconfigure $(TF_BACKEND_CONFIG))

tfiu:
	$(call tf_command,init,-upgrade $(TF_BACKEND_CONFIG))

tfre:
	$(call tf_command,refresh)

tfd:
	$(call tf_command,destroy)

# Docker commands
db:
	@echo "Building Docker image..."
	@cd server && docker buildx build $(DOCKER_PLATFORM) -t $(IMAGE_NAME) .

drb:
	@echo "Rebuilding Docker image with no cache..."
	@cd server && docker buildx build $(DOCKER_PLATFORM) --no-cache -t $(IMAGE_NAME) .

drun:
	@echo "Running Docker container..."
	@cd server && docker run -p 443:8000 -t $(IMAGE_NAME) .

dt:
	@echo "Tagging Docker image..."
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(TIMESTAMP)
	@docker tag $(IMAGE_NAME):latest $(ECR_URI):latest

dp:
	@echo "Pushing Docker image..."
	@cd server && \
	aws ecr get-login-password --region $(TF_VAR_AWS_REGION) | docker login --username AWS --password-stdin $(ECR_URI)
	@make dt
	@docker push $(ECR_URI)
