output "private_instance_ips" {
  value       = [for instance in aws_instance.private_instances : instance.private_ip]
  description = "Private IPs of the EC2 instances in private subnets"
}

output "instance_id" {
  value       = [for instance in aws_instance.private_instances : instance.id]
  description = "ID of the created EC2 instances"
}

output "load_balancer_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "windows_instance_ips" {
  value       = [for instance in aws_instance.windows_instances : instance.private_ip]
  description = "Public IP addresses of the Windows instances"
}

output "windows_instance_id" {
  value       = [for instance in aws_instance.windows_instances : instance.id]
  description = "ID of the created Windows instances"
}
