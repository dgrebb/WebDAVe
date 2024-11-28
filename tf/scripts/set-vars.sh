echo "One moment while I set up Terraform vars..."
export TF_VAR_AWS_ACCESS_KEY=$(pass dg/aws/id)
export TF_VAR_AWS_SECRET_KEY=$(pass dg/aws/secret)
export TF_VAR_AWS_REGION=$(pass dg/aws/region)
export TF_VAR_DOMAIN=$(pass webdav/domain)
export TF_VAR_SUBDOMAIN=$(pass webdav/subdomain)
export TF_VAR_DASHED_SUBDOMAIN=$(pass webdav/dashed-subdomain)
export IMAGE_NAME=$(pass webdav/image-name)
export ECR_URI=$(pass webdav/ecr-uri)
export AWS_STATE_BUCKET=$(pass webdav/state/bucket)
export AWS_STATE_KEY_PATH=$(pass webdav/state/path)
