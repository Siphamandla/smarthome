#!/bin/bash

# setup.sh - Raspberry Pi 5 setup script
# Interactive menu for SSH and Docker setup

set -e  # Exit on error

# ============================================
# FUNCTION DEFINITIONS
# ============================================

# SSH Setup function
setup_ssh() {
    echo "=================================="
    echo "SSH Configuration"
    echo "=================================="
    echo ""
    
    echo "Enabling SSH service..."
    sudo systemctl enable ssh
    sudo systemctl start ssh
    echo "✓ SSH enabled and started"
    echo ""
    
    echo "Your Raspberry Pi IP addresses:"
    hostname -I
    echo ""
    echo "💡 Use one of these IPs to connect via SSH from your Mac:"
    echo "   ssh $(whoami)@<ip-address>"
    echo ""
    echo "=================================="
    read -p "Press Enter to return to menu..."
}

# Docker Installation function
install_docker() {
    echo "=================================="
    echo "Docker Installation"
    echo "=================================="
    echo ""
    
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        echo "⚠️  Docker is already installed!"
        docker --version
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi
    
    # Update package lists and upgrade existing packages
    echo "[1/4] Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    echo "✓ System packages updated"
    echo ""
    
    # Install prerequisites
    echo "[2/4] Installing prerequisites..."
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    echo "✓ Prerequisites installed"
    echo ""
    
    # Install Docker
    echo "[3/4] Installing Docker..."
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    echo "✓ Docker installed"
    echo ""
    
    # Add current user to docker group
    echo "[4/4] Configuring Docker permissions..."
    sudo usermod -aG docker $USER
    echo "✓ User added to docker group"
    echo ""
    
    echo "=================================="
    echo "Docker Installation Complete!"
    echo "=================================="
    echo ""
    echo "Docker version:"
    docker --version
    echo ""
    echo "⚠️  IMPORTANT: You need to log out and log back in (or reboot)"
    echo "    for the docker group changes to take effect."
    echo ""
    read -p "Press Enter to return to menu..."
}

# Prepare Traefik function
prepare_traefik() {
    echo "=================================="
    echo "Prepare Traefik"
    echo "=================================="
    echo ""
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "⚠️  Error: Docker is not installed!"
        echo "    Please install Docker first (option 2)"
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi
    
    # Check if Docker Compose is installed
    if ! docker compose version &> /dev/null; then
        echo "⚠️  Error: Docker Compose is not installed!"
        echo "    Please install Docker Compose first (option 3)"
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi
    
    # Step 1: Setup acme.json
    echo "[1/3] Setting up acme.json for Let's Encrypt certificates..."
    ACME_FILE="./acme.json"
    
    if [ -f "$ACME_FILE" ]; then
        echo "⚠️  acme.json already exists (permissions: $(stat -c '%a' "$ACME_FILE" 2>/dev/null || stat -f '%Lp' "$ACME_FILE"))"
        read -p "Reset it? (y/n): " reset_choice
        if [ "$reset_choice" = "y" ] || [ "$reset_choice" = "Y" ]; then
            rm -f "$ACME_FILE"
            touch "$ACME_FILE"
            chmod 600 "$ACME_FILE"
            echo "✓ acme.json reset with permissions 600"
        else
            chmod 600 "$ACME_FILE" 2>/dev/null || true
            echo "✓ Ensured correct permissions on existing acme.json"
        fi
    else
        touch "$ACME_FILE"
        chmod 600 "$ACME_FILE"
        echo "✓ acme.json created with permissions 600"
    fi
    echo ""
    
    # Step 2: Stop Traefik if running
    echo "[2/3] Stopping existing Traefik container..."
    if docker ps -a --format '{{.Names}}' | grep -q '^traefik$'; then
        docker compose stop traefik
        docker compose rm -f traefik
        echo "✓ Traefik container stopped and removed"
    else
        echo "ℹ️  No existing Traefik container found"
    fi
    echo ""
    
    # Step 3: Rebuild and start Traefik
    echo "[3/3] Rebuilding and starting Traefik..."
    docker compose build --no-cache traefik
    docker compose up -d traefik
    echo "✓ Traefik rebuilt and started"
    echo ""
    
    # Show status
    echo "Waiting for Traefik to start..."
    sleep 3
    echo ""
    echo "Traefik Status:"
    docker compose ps traefik
    echo ""
    
    echo "=================================="
    echo "Traefik Preparation Complete!"
    echo "=================================="
    echo ""
    echo "📝 ACME.json: $ACME_FILE (permissions: $(stat -c '%a' "$ACME_FILE" 2>/dev/null || stat -f '%Lp' "$ACME_FILE"))"
    echo "🌐 Traefik Dashboard: http://localhost:8080"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Set ACME_EMAIL in .env file"
    echo "   2. Forward ports 80 and 443 on your router"
    echo "   3. Set up domain name for your API"
    echo ""
    read -p "Press Enter to return to menu..."
}

# Docker Compose Installation function
install_docker_compose() {
    echo "=================================="
    echo "Docker Compose Installation"
    echo "=================================="
    echo ""
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "⚠️  Error: Docker is not installed!"
        echo "    Please install Docker first (option 2)"
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi
    
    # Check if Docker Compose is already installed
    if docker compose version &> /dev/null; then
        echo "⚠️  Docker Compose is already installed!"
        docker compose version
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi
    
    echo "Installing Docker Compose plugin..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    echo "✓ Docker Compose installed"
    echo ""
    
    echo "=================================="
    echo "Docker Compose Installation Complete!"
    echo "=================================="
    echo ""
    echo "Docker Compose version:"
    docker compose version
    echo ""
    read -p "Press Enter to return to menu..."
}

# Update System function
update_system() {
    echo "=================================="
    echo "System Update"
    echo "=================================="
    echo ""
    
    echo "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    echo "✓ System packages updated"
    echo ""
    
    read -p "Press Enter to return to menu..."
}

# Show system info
show_info() {
    echo "=================================="
    echo "System Information"
    echo "=================================="
    echo ""
    
    echo "Hostname: $(hostname)"
    echo "IP Addresses: $(hostname -I)"
    echo ""
    
    echo "OS Information:"
    cat /etc/os-release | grep PRETTY_NAME
    echo ""
    
    echo "SSH Status:"
    sudo systemctl status ssh --no-pager | grep Active
    echo ""
    
    if command -v docker &> /dev/null; then
        echo "Docker Status:"
        echo "  Docker version: $(docker --version)"
        echo "  Docker Compose version: $(docker compose version)"
        echo "  Docker service: $(sudo systemctl is-active docker)"
    else
        echo "Docker: Not installed"
    fi
    echo ""
    
    read -p "Press Enter to return to menu..."
}

# ============================================
# MAIN MENU
# ============================================

show_menu() {
    clear
    echo "=================================="
    echo "Raspberry Pi 5 Setup Script"
    echo "=================================="
    echo ""
    echo "Select an option:"
    echo ""
    echo "  1) Enable SSH"
    echo "  2) Install Docker"
    echo "  3) Install Docker Compose"
    echo "  4) Prepare Traefik (ACME + Rebuild)"
    echo "  5) Update System Packages"
    echo "  6) Show System Information"
    echo "  7) Run All Setup Tasks"
    echo "  0) Exit"
    echo ""
    echo "=================================="
}

# Run all tasks
run_all() {
    echo "=================================="
    echo "Running All Setup Tasks"
    echo "=================================="
    echo ""
    
    setup_ssh
    echo ""
    install_docker
    echo ""
    install_docker_compose
    echo ""
    prepare_traefik
    
    echo ""
    echo "=================================="
    echo "All Setup Tasks Complete!"
    echo "=================================="
    echo ""
    read -p "Press Enter to return to menu..."
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-7]: " choice
    echo ""
    
    case $choice in
        1)
            setup_ssh
            ;;
        2)
            install_docker
            ;;
        3)
            install_docker_compose
            ;;
        4)
            prepare_traefik
            ;;
        5)
            update_system
            ;;
        6)
            show_info
            ;;
        7)
            run_all
            ;;
        0)
            echo "Exiting setup script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            ;;
    esac
done
