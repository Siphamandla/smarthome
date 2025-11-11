#!/bin/bash

# deploy-homeassistant.sh - Automated Home Assistant deployment script

set -e  # Exit on error

echo "=================================="
echo "Home Assistant Deployment"
echo "=================================="
echo ""

# Stop and remove existing containers
echo "[1/5] Stopping existing containers..."
docker compose down
echo "✓ Containers stopped"
echo ""

# Pull/build images
echo "[2/5] Pulling Home Assistant image..."
docker compose pull homeassistant
echo "✓ Image pulled"
echo ""

# Start containers
echo "[3/5] Starting containers..."
docker compose up -d
echo "✓ Containers started"
echo ""

# Wait for Home Assistant to initialize
echo "[4/5] Waiting for Home Assistant to initialize (30 seconds)..."
sleep 30
echo "✓ Initialization complete"
echo ""

# Copy configuration template on every deployment
echo "[5/5] Configuring Home Assistant..."
docker exec homeassistant sh -c '
  echo "Copying configuration.yaml from template..."
  cp /config/configuration.yaml.template /config/configuration.yaml
  echo "✓ Configuration updated from template"
'
echo ""

# Restart Home Assistant to apply configuration
echo "Restarting Home Assistant to apply configuration..."
docker restart homeassistant
echo "✓ Home Assistant restarted"
echo ""

echo "=================================="
echo "Deployment Complete!"
echo "=================================="
echo ""
echo "Access Home Assistant at:"
echo "  - HTTP:  http://192.168.68.122"
echo "  - HTTPS: https://192.168.68.122"
echo ""
echo "Check logs: docker logs -f homeassistant"
echo ""
