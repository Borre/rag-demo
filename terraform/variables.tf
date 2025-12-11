variable "huawei_region" {
  description = "Huawei Cloud region"
  type        = string
  default     = "cn-north-4"
}

variable "huawei_access_key" {
  description = "Huawei Cloud access key"
  type        = string
  sensitive   = true
}

variable "huawei_secret_key" {
  description = "Huawei Cloud secret key"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "radiology-ai"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for ECS"
  type        = string
  default     = "cn-north-4a"
}

variable "ecs_image_name" {
  description = "ECS image name"
  type        = string
  default     = "Standard_Ubuntu_20.04_latest"
}

variable "ecs_flavor" {
  description = "ECS flavor type"
  type        = string
  default     = "s6.large.2"  # 2 vCPUs, 4GB RAM
}

variable "eip_bandwidth" {
  description = "EIP bandwidth in Mbps"
  type        = number
  default     = 5
}

variable "ssh_public_key" {
  description = "SSH public key for ECS access"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "SSH private key for ECS access"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_ips" {
  description = "CIDR blocks allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "n8n_allowed_ips" {
  description = "CIDR blocks allowed for N8N access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "deploy_n8n" {
  description = "Whether to deploy N8N alongside the Flask app"
  type        = bool
  default     = false
}

variable "alarm_notification_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}

# Database Configuration
variable "db_host" {
  description = "PostgreSQL database host"
  type        = string
  default     = "localhost"
}

variable "db_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "postgres"
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

# DeepSeek API Configuration
variable "deepseek_api_key" {
  description = "DeepSeek API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "deepseek_base_url" {
  description = "DeepSeek API base URL"
  type        = string
  default     = "https://api.deepseek.com"
}