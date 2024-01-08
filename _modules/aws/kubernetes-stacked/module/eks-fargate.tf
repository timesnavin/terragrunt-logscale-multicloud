resource "aws_cloudwatch_log_group" "fargate" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/fargate"
  retention_in_days = 1

  # ... potentially other configuration ...
}