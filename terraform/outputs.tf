output "ecs_public_ip" {
  description = "Public IP address of the ECS instance"
  value       = huaweicloud_vpc_eip_v1.main.address
}

output "ecs_instance_id" {
  description = "ID of the ECS instance"
  value       = huaweicloud_compute_instance_v2.main.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = huaweicloud_vpc_v1.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = huaweicloud_vpc_subnet_v1.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${huaweicloud_vpc_eip_v1.main.address}:5000"
}

output "n8n_url" {
  description = "URL to access N8N (if deployed)"
  value       = var.deploy_n8n ? "http://${huaweicloud_vpc_eip_v1.main.address}:5678" : null
}

output "ssh_command" {
  description = "SSH command to connect to the ECS instance"
  value       = "ssh -i ~/.ssh/${var.project_name}-key root@${huaweicloud_vpc_eip_v1.main.address}"
}