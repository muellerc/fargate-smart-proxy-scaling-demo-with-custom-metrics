provider "aws" {
    region     = "eu-central-1"
}

terraform {
    backend "s3" {
        bucket  = "cmr-terraform-backend-store"
        encrypt = true
        key     = "fargate-smart-proxy-scaling-demo-with-custom-metrics/terraform.tfstate"
        region  = "eu-central-1"
    }
}

resource "aws_ssm_parameter" "cw_agent_prometheus_config" {
    name        = "AmazonCloudWatch-PrometheusConfig"
    type        = "String"
    value       = file("AmazonCloudWatch-PrometheusConfig.yaml")
}

resource "aws_ssm_parameter" "cw_agent_config" {
    name        = "AmazonCloudWatch-CWAgentConfig"
    type        = "String"
    value       = file("AmazonCloudWatch-CWAgentConfig.json")
}

resource "aws_ecs_task_definition" "cloudwatch_agent_prometheus_task_definition" {
    family = "cloudwatch_agent_prometheus_task_definition"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 512
    memory                   = 1024
    execution_role_arn       = var.task_execution_role_arn
    task_role_arn            = var.task_role_arn
    container_definitions = jsonencode([{
        name        = "cloudwatch_agent_prometheus_container_definition"
        image       = "amazon/cloudwatch-agent:latest"
        essential   = true
        secrets = [
            {
                name = "PROMETHEUS_CONFIG_CONTENT"
                valueFrom = "AmazonCloudWatch-PrometheusConfig"
            },
            {
                name = "CW_CONFIG_CONTENT"
                valueFrom = "AmazonCloudWatch-CWAgentConfig"
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group         = "/ecs/cloudwatch-agent-prometheus"
                awslogs-stream-prefix = "ecs"
                awslogs-region        = "eu-central-1"
            }
        }
    }])
}

resource "aws_ecs_service" "cloudwatch_agent_prometheus_service" {
    name                               = "cloudwatch_agent_prometheus_service"
    cluster                            = var.ecs_cluster_arn
    task_definition                    = aws_ecs_task_definition.cloudwatch_agent_prometheus_task_definition.arn
    desired_count                      = 1
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent         = 200
    launch_type                        = "FARGATE"
    scheduling_strategy                = "REPLICA"

    network_configuration {
        security_groups  = var.cloudwatch_agent_prometheus_security_groups
        subnets          = var.cloudwatch_agent_prometheus_subnets
        assign_public_ip = false
    }
}