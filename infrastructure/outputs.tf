# -----------------------------------------------------------------------------
# Observability stack endpoints
# -----------------------------------------------------------------------------
output "ec2_public_ip" {
  description = "Public IP of the observability EC2 instance."
  value       = module.observability.instance_public_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL."
  value       = "http://${module.observability.instance_public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus UI URL."
  value       = "http://${module.observability.instance_public_ip}:9090"
}

output "app_url" {
  description = "Web application URL (metrics at /metrics)."
  value       = "http://${module.observability.instance_public_ip}:4000"
}

output "ssh_command" {
  description = "Example SSH command to the instance."
  value       = "ssh -i <your-key.pem> ubuntu@${module.observability.instance_public_ip}"
}
