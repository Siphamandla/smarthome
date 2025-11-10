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
    echo "  4) Update System Packages"
    echo "  5) Show System Information"
    echo "  6) Run All Setup Tasks"
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
    echo "=================================="
    echo "All Setup Tasks Complete!"
    echo "=================================="
    echo ""
    read -p "Press Enter to return to menu..."
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-6]: " choice
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
            update_system
            ;;
        5)
            show_info
            ;;
        6)
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
