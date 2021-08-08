variable "ecs_cluster_arn" {
    description = "The ARN of your existing Amazon ECS cluster"
}

variable "task_role_arn" {
    description = "This role provides permissions to your container to access other AWS services."
}

variable "task_execution_role_arn" {
    description = "This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf."
}

variable "cloudwatch_agent_prometheus_security_groups" {
    description = "The ID of the security groups we assign to the service."
    type    = list(string)
}

variable "cloudwatch_agent_prometheus_subnets" {
    description = "The ID of the subnets we assign to the service."
    type    = list(string)
}