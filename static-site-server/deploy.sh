#!/bin/bash

# =============================================================================
# Website Deployment Script
# =============================================================================
# This script automatically deploys your static website to Azure VM using rsync
# 
# Usage: ./deploy.sh [environment]
# Example: ./deploy.sh production
#          ./deploy.sh staging
#          ./deploy.sh (defaults to production)
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# CONFIGURATION - UPDATE THESE VALUES
# =============================================================================

# Default environment
ENVIRONMENT=${1:-production}

# Server configurations
case $ENVIRONMENT in
    "production")
        SERVER_USER="azureuser"
        SERVER_HOST="172.206.195.75"  # Replace with your actual VM IP
        SERVER_PATH="/var/www/html/"
        ;;
    # "staging")
    #     SERVER_USER="azureuser"
    #     SERVER_HOST="your-staging-ip"  # Replace with staging server IP
    #     SERVER_PATH="/var/www/staging/"
    #     ;;
    *)
        echo -e "${RED}❌ Unknown environment: $ENVIRONMENT${NC}"
        echo "Available environments: production"
        exit 1
        ;;
esac

# Local directory containing your website files
LOCAL_DIR="./website/" 

# Files/directories to exclude from deployment
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "node_modules"
    ".DS_Store"
    "*.log"
    ".env"
    "README.md"
    "deploy.sh"
    ".vscode"
    "*.tmp"
    "*.bak"
)

# =============================================================================
# FUNCTIONS
# =============================================================================

print_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║         Website Deployment             ║"
    echo "║            Azure VM + Rsync            ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}🔄 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_requirements() {
    print_step "Checking requirements..."
    
    # Check if rsync is installed
    if ! command -v rsync &> /dev/null; then
        print_error "rsync is not installed. Please install rsync first."
        exit 1
    fi
    
    # Check if SSH is available
    if ! command -v ssh &> /dev/null; then
        print_error "SSH is not available. Please install SSH client."
        exit 1
    fi
    
    # Check if local directory exists
    if [ ! -d "$LOCAL_DIR" ]; then
        print_error "Local directory '$LOCAL_DIR' does not exist."
        print_warning "Please update LOCAL_DIR in the script or create the directory."
        exit 1
    fi
    
    print_success "All requirements met!"
}

test_connection() {
    print_step "Testing SSH connection to $SERVER_HOST..."
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_HOST" "echo 'Connection successful'" &> /dev/null; then
        print_success "SSH connection successful!"
    else
        print_error "Cannot connect to $SERVER_HOST"
        print_warning "Please check:"
        echo "  - Server IP address is correct"
        echo "  - SSH key is properly configured"
        echo "  - Server is running and accessible"
        exit 1
    fi
}

build_exclude_options() {
    EXCLUDE_OPTIONS=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        EXCLUDE_OPTIONS="$EXCLUDE_OPTIONS --exclude='$pattern'"
    done
}

show_deployment_info() {
    echo -e "${YELLOW}"
    echo "📋 Deployment Information:"
    echo "   Environment: $ENVIRONMENT"
    echo "   Local Dir:   $LOCAL_DIR"
    echo "   Server:      $SERVER_USER@$SERVER_HOST"
    echo "   Remote Path: $SERVER_PATH"
    echo "   Excluded:    ${EXCLUDE_PATTERNS[*]}"
    echo -e "${NC}"
}

dry_run() {
    print_step "Performing dry run (no files will be transferred)..."
    
    # Build exclude options
    build_exclude_options
    
    # Perform dry run
    eval "rsync -avz --dry-run --delete $EXCLUDE_OPTIONS '$LOCAL_DIR' '$SERVER_USER@$SERVER_HOST:$SERVER_PATH'"
    
    echo
    read -p "🤔 Do you want to proceed with the actual deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user."
        exit 0
    fi
}

deploy_files() {
    print_step "Starting file deployment..."
    
    # Build exclude options
    build_exclude_options
    
    # Perform actual rsync
    echo "Running: rsync -avz --delete $EXCLUDE_OPTIONS '$LOCAL_DIR' '$SERVER_USER@$SERVER_HOST:$SERVER_PATH'"
    
    if eval "rsync -avz --delete --progress $EXCLUDE_OPTIONS '$LOCAL_DIR' '$SERVER_USER@$SERVER_HOST:$SERVER_PATH'"; then
        print_success "Files deployed successfully!"
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

fix_permissions() {
    print_step "Fixing file permissions on server..."
    
    if ssh "$SERVER_USER@$SERVER_HOST" "sudo chown -R www-data:www-data $SERVER_PATH && sudo chmod -R 755 $SERVER_PATH"; then
        print_success "Permissions fixed!"
    else
        print_warning "Could not fix permissions. You may need to do this manually."
    fi
}

restart_nginx() {
    print_step "Restarting nginx on server..."
    
    if ssh "$SERVER_USER@$SERVER_HOST" "sudo systemctl restart nginx"; then
        print_success "Nginx restarted successfully!"
    else
        print_warning "Could not restart nginx. Website should still work with cached content."
    fi
}

verify_deployment() {
    print_step "Verifying deployment..."
    
    # Test if server responds
    if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_HOST" | grep -q "200"; then
        print_success "Website is responding correctly!"
        echo -e "${GREEN}🌐 Your website is live at: http://$SERVER_HOST${NC}"
    else
        print_warning "Website might not be responding. Please check manually."
    fi
}

cleanup() {
    print_step "Cleaning up temporary files..."
    # Add any cleanup tasks here if needed
    print_success "Cleanup completed!"
}

show_help() {
    echo "Website Deployment Script"
    echo ""
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo ""
    echo "Environments:"
    echo "  production  Deploy to production server (default)"
    echo "  staging     Deploy to staging server"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --dry-run  Show what would be deployed without actually deploying"
    echo ""
    echo "Examples:"
    echo "  $0                    # Deploy to production"
    echo "  $0 production         # Deploy to production"
    echo "  $0 staging            # Deploy to staging"
    echo "  $0 production --dry-run  # See what would be deployed"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse command line arguments
    case "${2:-}" in
        "-h"|"--help")
            show_help
            exit 0
            ;;
        "-d"|"--dry-run")
            DRY_RUN=true
            ;;
    esac
    
    # Start deployment process
    print_banner
    
    show_deployment_info
    
    check_requirements
    
    test_connection
    
    if [ "${DRY_RUN:-false}" = true ]; then
        dry_run
    else
        # Ask for confirmation for production deployments
        if [ "$ENVIRONMENT" = "production" ]; then
            echo
            read -p "🚨 You are deploying to PRODUCTION. Continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_warning "Deployment cancelled."
                exit 0
            fi
        fi
        
        dry_run
    fi
    
    deploy_files
    
    fix_permissions
    
    restart_nginx
    
    verify_deployment
    
    cleanup
    
    echo
    print_success "🎉 Deployment completed successfully!"
    echo -e "${GREEN}🌐 Visit your website: http://$SERVER_HOST${NC}"
    
    # Show deployment summary
    echo
    echo -e "${BLUE}📊 Deployment Summary:${NC}"
    echo "   Environment: $ENVIRONMENT"
    echo "   Server: $SERVER_HOST"
    echo "   Time: $(date)"
    echo "   Status: SUCCESS ✅"
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Deployment interrupted!${NC}"; exit 1' INT TERM

# Run main function with all arguments
main "$@"