#!/bin/bash

# Huawei Cloud Deployment Script for Radiology Triage AI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi

    # Check if terraform.tfvars exists
    if [ ! -f "terraform/terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from template..."
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        print_warning "Please edit terraform/terraform.tfvars with your configuration"
        print_warning "After editing, run this script again"
        exit 1
    fi

    # Check if required variables are set
    if grep -q "your_access_key_here" terraform/terraform.tfvars || \
       grep -q "your_secret_key_here" terraform/terraform.tfvars; then
        print_error "Please configure your Huawei Cloud credentials in terraform/terraform.tfvars"
        exit 1
    fi

    print_status "Prerequisites check passed ✓"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Starting infrastructure deployment..."

    cd terraform

    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init

    # Validate configuration
    print_status "Validating Terraform configuration..."
    terraform validate

    # Plan deployment
    print_status "Creating execution plan..."
    terraform plan -out=tfplan

    # Show plan summary
    print_status "Deployment plan created. Review the changes above."
    read -p "Do you want to proceed with deployment? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Terraform configuration..."
        terraform apply tfplan

        # Get outputs
        print_status "Deployment completed! Getting outputs..."
        ECS_IP=$(terraform output -raw ecs_public_ip)
        APP_URL=$(terraform output -raw application_url)
        SSH_CMD=$(terraform output -raw ssh_command)

        echo ""
        print_status "=== DEPLOYMENT RESULTS ==="
        echo "ECS Public IP: $ECS_IP"
        echo "Application URL: $APP_URL"
        echo "SSH Command: $SSH_CMD"
        echo ""

        cd ..
    else
        print_warning "Deployment cancelled."
        cd ..
        exit 1
    fi
}

# Wait for application to be ready
wait_for_app() {
    print_status "Waiting for application to be ready..."

    ECS_IP=$(cd terraform && terraform output -raw ecs_public_ip)
    APP_URL="http://$ECS_IP:5000"

    # Wait up to 5 minutes for the app to start
    for i in {1..30}; do
        if curl -s -o /dev/null -w "%{http_code}" $APP_URL | grep -q "200"; then
            print_status "Application is ready! ✓"
            print_status "Access it at: $APP_URL"
            return 0
        fi
        print_status "Attempt $i/30: Application not ready yet, waiting 10 seconds..."
        sleep 10
    done

    print_error "Application failed to start within 5 minutes"
    print_error "Please SSH into the instance and check the logs"
    return 1
}

# Main execution
main() {
    echo "====================================="
    echo "Radiology Triage AI - Huawei Cloud Deployment"
    echo "====================================="
    echo ""

    check_prerequisites
    deploy_infrastructure

    # Wait for application to be ready
    if wait_for_app; then
        print_status "🎉 Deployment successful!"
        echo ""
        print_status "Next steps:"
        print_status "1. Access your application at the URL above"
        print_status "2. Configure your database connection if not done already"
        print_status "3. Add your DeepSeek API key to the .env file on the server"
        print_status "4. Start using the radiology triage system!"
        echo ""
        print_status "To manage your deployment:"
        print_status "- SSH to server: $SSH_CMD"
        print_status "- View logs: docker-compose logs -f"
        print_status "- Stop app: docker-compose down"
        print_status "- Update app: git pull && docker-compose up --build -d"
    else
        print_error "Deployment encountered issues. Please check the logs."
        exit 1
    fi
}

# Handle script interruption
trap 'print_warning "Deployment interrupted"; exit 1' INT

# Run main function
main "$@"