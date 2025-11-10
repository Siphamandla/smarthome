#!/bin/bash

# setup.sh - Raspberry Pi 5 setup script
# Enables SSH and installs Docker with Docker Compose

set -e  # Exit on error

echo "=================================="
echo "Raspberry Pi 5 Setup Script"
echo "=================================="
echo ""

# ============================================
# SSH SETUP
# ============================================
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
read -p "Press Enter to continue with Docker installation..."
echo ""

# ============================================
# DOCKER INSTALLATION
# ============================================
echo "=================================="
echo "Docker Installation"
echo "=================================="
echo ""

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

# Install Docker Engine and Docker Compose plugin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "✓ Docker installed"
echo ""

# Add current user to docker group
echo "[4/4] Configuring Docker permissions..."
sudo usermod -aG docker $USER
echo "✓ User added to docker group"
echo ""

echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker compose version
echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in (or reboot)"
echo "    for the docker group changes to take effect."
echo ""
