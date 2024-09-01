output "bastion_public_ip" {
  value       = aws_instance.bastion_host.public_ip
  description = "Public IP of the bastion host"
}

output "private_instance_ips" {
  value       = aws_instance.private_instances.*.private_ip
  description = "Private IPs of the EC2 instances in private subnets"
}

output "load_balancer_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
  description = "DNS name of the Application Load Balancer"
}
