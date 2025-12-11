# Huawei Cloud Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.50"
    }
  }
}

# Configure Huawei Cloud Provider
provider "huaweicloud" {
  region     = var.huawei_region
  access_key = var.huawei_access_key
  secret_key = var.huawei_secret_key
}

# Random ID for unique resource naming
resource "random_id" "unique" {
  byte_length = 4
}

# VPC Configuration
resource "huaweicloud_vpc_v1" "main" {
  name = "${var.project_name}-vpc-${random_id.unique.hex}"
  cidr = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
    Project = var.project_name
    Environment = var.environment
  }
}

# Subnet Configuration
resource "huaweicloud_vpc_subnet_v1" "main" {
  name       = "${var.project_name}-subnet-${random_id.unique.hex}"
  vpc_id     = huaweicloud_vpc_v1.main.id
  cidr       = var.subnet_cidr
  gateway_ip = cidrhost(var.subnet_cidr, 1)

  tags = {
    Name = "${var.project_name}-subnet"
    Project = var.project_name
    Environment = var.environment
  }
}

# Security Group
resource "huaweicloud_networking_secgroup_v2" "ecs_secgroup" {
  name        = "${var.project_name}-ecs-sg-${random_id.unique.hex}"
  description = "Security group for Radiology Triage ECS"

  tags = {
    Name = "${var.project_name}-ecs-sg"
    Project = var.project_name
    Environment = var.environment
  }
}

# Security Group Rules
resource "huaweicloud_networking_secgroup_rule_v2" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = var.ssh_allowed_ips
  security_group_id = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

resource "huaweicloud_networking_secgroup_rule_v2" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5000
  port_range_max    = 5000
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

resource "huaweicloud_networking_secgroup_rule_v2" "allow_n8n" {
  count             = var.deploy_n8n ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5678
  port_range_max    = 5678
  protocol          = "tcp"
  remote_ip_prefix  = var.n8n_allowed_ips
  security_group_id = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

resource "huaweicloud_networking_secgroup_rule_v2" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

resource "huaweicloud_networking_secgroup_rule_v2" "allow_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  port_range_min    = 0
  port_range_max    = 0
  protocol          = "all"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup_v2.ecs_secgroup.id
}

# SSH Key Pair
resource "huaweicloud_compute_keypair_v2" "main" {
  name       = "${var.project_name}-key-${random_id.unique.hex}"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.project_name}-key"
    Project = var.project_name
    Environment = var.environment
  }
}

# ECS Instance
resource "huaweicloud_compute_instance_v2" "main" {
  name              = "${var.project_name}-ecs-${random_id.unique.hex}"
  image_name        = var.ecs_image_name
  flavor_name       = var.ecs_flavor
  key_pair          = huaweicloud_compute_keypair_v2.main.name
  availability_zone = var.availability_zone

  network {
    uuid = huaweicloud_vpc_subnet_v1.main.id
  }

  security_groups = [huaweicloud_networking_secgroup_v2.ecs_secgroup.name]

  tags = {
    Name = "${var.project_name}-ecs"
    Project = var.project_name
    Environment = var.environment
    Role = "web-server"
  }
}

# EIP (Elastic IP) for ECS
resource "huaweicloud_vpc_eip_v1" "main" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project_name}-eip-${random_id.unique.hex}"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# Associate EIP with ECS
resource "huaweicloud_compute_floatingip_associate_v2" "main" {
  floating_ip = huaweicloud_vpc_eip_v1.main.address
  instance_id = huaweicloud_compute_instance_v2.main.id
}

# Cloud Eye Alarm for ECS CPU
resource "huaweicloud_ces_alarmrule" "ecs_cpu" {
  alarm_name        = "${var.project_name}-ecs-cpu-high"
  alarm_type        = "event.metric"
  alarm_action_type = "notification"
  alarm_enabled     = true

  alarm_actions = [var.alarm_notification_email]

  metric_name = "cpu_util"
  resource_id = huaweicloud_compute_instance_v2.main.id
  namespace   = "SYS.ECS"

  condition {
    period             = 300
    filter             = "average"
    comparison_operator = ">="
    value              = 80
    unit               = "percent"
    count              = 2
  }

  tags = {
    Name = "${var.project_name}-cpu-alarm"
    Project = var.project_name
    Environment = var.environment
  }
}

# Local file for deployment script
data "template_file" "deploy_script" {
  template = file("${path.module}/deploy.sh.template")

  vars = {
    project_name           = var.project_name
    db_host               = var.db_host
    db_port               = var.db_port
    db_name               = var.db_name
    db_user               = var.db_user
    db_password           = var.db_password
    deepseek_api_key      = var.deepseek_api_key
    deepseek_base_url     = var.deepseek_base_url
    deploy_n8n           = var.deploy_n8n
    docker_compose_file  = var.deploy_n8n ? "docker-compose-full.yml" : "docker-compose.yml"
  }
}

# Create deployment script on ECS
resource "huaweicloud_compute_instance_v2" "deploy" {
  depends_on = [huaweicloud_compute_instance_v2.main]

  # Use null_resource to run remote commands
  connection {
    type        = "ssh"
    host        = huaweicloud_vpc_eip_v1.main.address
    user        = "root"
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    content     = data.template_file.deploy_script.rendered
    destination = "/tmp/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy.sh",
      "/tmp/deploy.sh"
    ]
  }
}