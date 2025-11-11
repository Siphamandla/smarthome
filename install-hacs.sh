#!/bin/bash

# install-hacs.sh - Install Home Assistant Community Store (HACS)

set -e  # Exit on error

echo "=================================="
echo "HACS Installation"
echo "=================================="
echo ""

echo "Installing HACS..."
docker exec homeassistant sh -c 'wget -O - https://get.hacs.xyz | bash -'
echo "✓ HACS installed"
echo ""

echo "Restarting Home Assistant..."
docker restart homeassistant
echo "✓ Home Assistant restarted"
echo ""

echo "=================================="
echo "HACS Installation Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Wait for Home Assistant to restart (30 seconds)"
echo "2. Go to: Settings → Devices & Services"
echo "3. You should see 'HACS' ready to configure"
echo "4. Click 'Configure' and follow the GitHub authentication"
echo "5. After HACS is set up, search for 'Eufy Security' in HACS"
echo ""
echo "Or visit: https://192.168.68.122/config/integrations"
echo ""
