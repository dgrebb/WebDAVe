# AWS ECS EFS WebDAV Server

A [`dave`](https://github.com/micromata/dave) Docker setup for AWS Elastic Container Service, as well as Terraform to provision infrastructure.

## Getting Started

* clone the repo

### Set up `dave` and the `Dockerfile`

* rename `server/config.example.yaml` 👉 `config.yaml`
* adjust the values to your liking
* create certificates for TLS by following the `dave` [README](server/README.md) or comment out the `tls` section
* use the `dave` cli to generate passwords for `server/config.example.yaml` running `cd server && go run cmd/davecli/main.go passwd`
  * you may need to [install `go`](https://go.dev/doc/install) first
* adjust paths in `server/Dockerfile` to suit your needs

### Configure Terraform

I use [`pass`](https://www.passwordstore.org/) to manage secrets and inject them when running Docker and Terraform commands. You can set this up yourself, or set the values in plaintext in the `tf/scripts/set-tf-vars.example.sh` script.

* rename `tf/scripts/set-tf-vars.example.sh` 👉 `set-tf-vars.sh`
  * ensure this file is executable by running `chmod a+x tf/scripts/set-tf-vars.sh`
* use whatever domain/subdomain your heart desires
  * *note*: at the time of writing, this setup requires a subdomain
* run `make tfi` to initialize Terraform
  * if enabling s3 backend, you'll be asked for the bucket name, key, and region - name must be `webdav-state` unless you'd like to adjust its value in `vars.tf`

### Configure `Makefile`

* As with Terraform, secrets are injected via `pass` by default. You can set up `pass`, or set the variables at the top of `Makefile` in plaintext.

## Deploying to AWS 🚀

First, we need to set up the ECR repository. We'll run `make tfa` and answer "yes" to the prompt. This will provision everything but the ECS Cluster, Service, and Task. We need to build and deploy the Docker image to ECR first. Follow the steps below.

**Important**: Note that the `Makefile` uses `docker buildx build` and a target architecture of `linux/amd64`. This builds Docker images for AWS ECS on M1/M2 Macs, which default to building with the Apple silicon ARM architecture.

### Provision the Initial Infrastructure and ECR Repository

* if you haven't already, run `make tfi` to initialize Terraform
* run `make tfa` to provision your infrastructure
  * **note**: as mentioned above, the first run will yield no ECS Cluster, Service, or Tasks — because the ECR repository is currently empty... we'll fix that in the next section.

### Build and Push the Docker Image

First, be sure to set your `ECR_URI` variable in `Makefile` now that the AWS ECR repo is set up.

* run `make db`, which will build the Docker image and name the target what is specified in the `IMAGE_NAME` variable at the top of `Makefile`
* run `make dp`, which will login to AWS, tag the image with build time and  "`latest`", and push it to the ECR repo set via `ECR_URI` at the top of `Makefile`
* check the [AWS Console](https://console.aws.amazon.com/ecr/repositories) to ensure your image has been pushed
  * be sure you are in the region specified in `Makefile` and `tf/scripts/set-tf-vars.sh`

### Provision the Final Infrastructure

* modify `tf/modules/cluster/cluster.tf` as such:
  * uncomment [lines 32-35](https://github.com/dgrebb/aws-ecs-efs-webdav-server/blob/main/tf/modules/cluster/cluster.tf#L32)
    * this section will pull the latest image digest
  * comment [line 41](https://github.com/dgrebb/aws-ecs-efs-webdav-server/blob/main/tf/modules/cluster/cluster.tf#L41)
  * uncomment [line 44](https://github.com/dgrebb/aws-ecs-efs-webdav-server/blob/main/tf/modules/cluster/cluster.tf#L44)
    * this will attach the latest image digest to your ECS Cluster Task Definition, which will recreate the resource any time a new version of the image is found
* run `make tfi` once more if you've changed anything since the first steps in this README
* run `make tfp` to check what actions Terraform will be performing
* run `make tfa`
* when prompted, type `yes`, and hit "Enter/Return"
* celebrate

*Note*: As this is a WebDAV server, there is nothing to open in the browser. You can check if your users/passwords are working by going to `https://subdomain.example.net`, but the browser won't know what to do after you authenticate.

Connectivity can be checked in macos by using Finder:

* open a Finder window
* hit **cmd+k**
* type `https://subdomain.example.com` and click "Connect"
* you will be prompted for user/pass (these are what was set up in `server/config/config.yaml`)

## Useful Commands

The [`Makefile`](Makefile) includes useful short commands that apply the project variables you've set in the [Getting Started](#getting-started) section.

## Credits

Heavily based on [Micromata](https://www.micromata.de)'s WebDAV server [`dave`](https://github.com/micromata/dave). A HUGE <a href="https://media.tenor.com/nRGEAAQstUEAAAAd/robert-redford-nod.gif" target="_blank">thank you</a>! 🙇‍♂️