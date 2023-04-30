resource "aws_ecs_cluster" "webdav_cluster" {
  name = var.DASHED_SUBDOMAIN # Name your cluster here
}

resource "aws_ecs_service" "webdav_service" {
  name                   = "webdav-service"                   # Name the service
  cluster                = aws_ecs_cluster.webdav_cluster.id # Reference the created Cluster
  task_definition        = aws_ecs_task_definition.webdav.arn # Reference the task that the service will spin up
  launch_type            = "FARGATE"
  # platform_version       = "1.4.0" - possibly remove; added for efs mount
  desired_count          = 1 # Set up the number of containers to 1
  force_new_deployment   = true
  enable_execute_command = true


  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn # Reference the target group
    container_name   = aws_ecs_task_definition.webdav.family
    container_port   = 8000 # Specify the container port
  }

  network_configuration {
    subnets          = [for subnet in var.subnet_ids : subnet]
    assign_public_ip = true                         # Provide the containers with public IPs
    security_groups  = ["${var.security_group_id}"] # Set up the security group
  }
}

# use this with the below image value if recreating task when new image is found
data "aws_ecr_image" "webdav_image" {
  repository_name = var.SUBDOMAIN
  image_tag       = "latest"
}

resource "aws_ecs_task_definition" "webdav" {
  family = "webdav" # Name your task
  container_definitions = jsonencode([{
    name                   = "webdav",
    # image                  = "${var.server_image}" 
    # use the below to push with image changes
    image = "${var.server_image}@${data.aws_ecr_image.webdav_image.image_digest}"
    essential              = true,
    network_mode           = "awsvpc",
    readonlyRootFilesystem = false
    memory                 = 1024,
    cpu                    = 512,
    force_new_deployment   = true
    portMappings = [
      {
        containerPort = 8000,
        hostPort      = 8000
      }
    ],
    mountPoints = [
      {
        containerPath = "/home/webdav/efs"
        sourceVolume  = "efs-webdav"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = var.SUBDOMAIN,
        awslogs-region        = var.REGION,
        awslogs-stream-prefix = "streaming"
      }
    }
    healthCheck = {
      command = [
        "CMD-SHELL",
        "pgrep dave || exit 1"
      ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 30
    },
  }])
  volume {
    name = "efs-webdav"
    efs_volume_configuration {
      file_system_id = var.efs_volume.id
      root_directory = "/"
    }
  }
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 1024        # Specify the memory the container requires
  cpu                      = 512         # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.webdav_ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.webdav_ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "webdav_ecsTaskExecutionRole" {
  name               = "webdav-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.webdav_ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMFullAccess_policy" {
  role       = aws_iam_role.webdav_ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
