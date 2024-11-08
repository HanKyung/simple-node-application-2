
# creating the ecr
# resource "aws_ecr_repository" "aws-ecr" {
#   name = "stephen-${var.app_name}-${var.app_environment}-ecr"
#   tags = {
#     Name        = "stephen-${var.app_name}-ecr"
#     Environment = var.app_environment
#   }
# }

# get existing ecr
# data "aws_ecr_repository" "aws-ecr"{
#     name = "stephen-${var.app_name}-${var.app_environment}-ecr"
# }



# creating ecs cluster
resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "stephen-${var.app_name}-${var.app_environment}-cluster"
  tags = {
    Name        = "stephen-${var.app_name}-ecs"
    Environment = var.app_environment
  }
}



resource "aws_cloudwatch_log_group" "log-group" {
  name = "stephen-${var.app_name}-${var.app_environment}-logs"

  tags = {
    Application = var.app_name
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${var.image_url}",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "stephen-${var.app_name}-${var.app_environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = "arn:aws:iam::255945442255:role/ecsTaskExecutionRole" # aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = "arn:aws:iam::255945442255:role/ecsTaskExecutionRole" # aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}


data "aws_subnets" "existing_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.aws-vpc.id]
  }
}
resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "stephen-${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  desired_count        = 1
  platform_version = "LATEST"
  # scheduling_strategy  = "REPLICA"
  # force_new_deployment = true


  network_configuration {
    subnets          =  aws_subnet.public.*.id # aws_subnet.private.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}



