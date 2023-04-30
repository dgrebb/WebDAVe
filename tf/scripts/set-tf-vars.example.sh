export TF_VAR_AWS_ACCESS_KEY=$(pass aws/id)
export TF_VAR_AWS_SECRET_KEY=$(pass aws/secret)
export TF_VAR_REGION="us-east-1"
export TF_VAR_DOMAIN="example.net"
export TF_VAR_SUBDOMAIN="subdomain.example.net"
export TF_VAR_DASHED_SUBDOMAIN="subdomain-example-net"