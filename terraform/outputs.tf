output "instance_public_ip" {
  description = "Public IP of the EC2 instance (Elastic IP)"
  value       = aws_eip.dumbbudget.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.dumbbudget.public_dns
}

output "app_url" {
  description = "URL to access the DumbBudget application"
  value       = "http://${aws_eip.dumbbudget.public_ip}"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_eip.dumbbudget.public_ip}:3001"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_eip.dumbbudget.public_ip}:9090"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i your-key.pem ubuntu@${aws_eip.dumbbudget.public_ip}"
}