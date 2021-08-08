provider "aws" {
    region     = "eu-central-1"
}

terraform {
    backend "s3" {
        bucket  = "cmr-terraform-backend-store"
        encrypt = true
        key     = "fargate-smart-proxy-scaling-demo-with-custom-metrics/cw-agent-config/terraform.tfstate"
        region  = "eu-central-1"
    }
}

resource "aws_ssm_parameter" "cw_agent_config" {
    name        = "AmazonCloudWatch-AgentConfig"
    type        = "String"
    value       = file("AmazonCloudWatch-AgentConfig.json")
}

# see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Generation_CloudWatch_Agent.html
resource "aws_ecs_task_definition" "smart_proxy_with_cloudwatch_agent_sidecar_task_definition" {
    family = "smart_proxy_with_cloudwatch_agent_sidecar_task_definition"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 2048
    memory                   = 4096
    execution_role_arn       = var.task_execution_role_arn
    task_role_arn            = var.task_role_arn
    container_definitions = jsonencode([
        {
            name        = "smart_proxy_container_definition"
            image       = "nginx:latest"
            essential   = true
            portMappings = [{
                containerPort = 80
            }]
            environment = [
                {
                    name = "AWS_EMF_AGENT_ENDPOINT"
                    value = "tcp://127.0.0.1:25888"
                }
            ]
            dockerLabels = {
                Java_EMF_Metrics             = "true"
                ECS_PROMETHEUS_JOB_NAME      = "cwagent-ecs-file-sd-config"
                ECS_PROMETHEUS_EXPORTER_PORT = "8080"
            }
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group         = "/ecs/smart_proxy"
                    awslogs-stream-prefix = "ecs"
                    awslogs-region        = "eu-central-1"
                }
            }
        },
        {
            name        = "cloudwatch_agent_container_definition"
            image       = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest"
            portMappings = [{
                containerPort = 25888
                protocol      = "tcp"
            }]
            secrets = [
                {
                    name = "CW_CONFIG_CONTENT"
                    valueFrom = "AmazonCloudWatch-AgentConfig"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group         = "/ecs/cloudwatch-agent"
                    awslogs-stream-prefix = "ecs"
                    awslogs-region        = "eu-central-1"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "smart_proxy_with_cloudwatch_agent_sidecar_service" {
    name                               = "smart_proxy_with_cloudwatch_agent_sidecar_service"
    cluster                            = var.ecs_cluster_arn
    task_definition                    = aws_ecs_task_definition.smart_proxy_with_cloudwatch_agent_sidecar_task_definition.arn
    desired_count                      = 1
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent         = 200
    launch_type                        = "FARGATE"
    scheduling_strategy                = "REPLICA"

    network_configuration {
        security_groups  = var.smart_proxy_with_cloudwatch_agent_sidecar_security_groups
        subnets          = var.smart_proxy_with_cloudwatch_agent_sidecar_subnets
        assign_public_ip = false
    }
}