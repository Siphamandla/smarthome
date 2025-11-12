# Smart Home - Home Assistant on Raspberry Pi 5

This project runs Home Assistant in Docker on a Raspberry Pi 5, providing comprehensive smart home automation with built-in HomeKit support.

## Prerequisites

- Raspberry Pi 5 with Raspberry Pi OS
- Internet connection

## Quick Start

### 1. Initial Setup (First Time Only)

Run the setup script to prepare your Raspberry Pi:

```bash
./setup.sh
```

This will:
- Update system packages
- Install Docker and Docker Compose
- Configure Docker permissions

**Important:** Reboot after running the setup script for changes to take effect.

### 2. Start Home Assistant

Build and start the Home Assistant container:

```bash
docker compose up -d
```

### 3. Configure Environment (Optional)

Copy the example environment file and customize:

```bash
cp .env.example .env
nano .env
```

Update the hostnames if needed:
- `HA_HOST`: Domain for Home Assistant (default: `homeassistant.localhost`)
- `TRAEFIK_HOST`: Domain for Traefik dashboard (default: `traefik.localhost`)

### 4. Access Services

**Home Assistant:**
```
http://homeassistant.localhost
# or
http://<raspberry-pi-ip>:8123
```

**Traefik Dashboard:**
```
http://traefik.localhost
# or
http://<raspberry-pi-ip>:8080
```

On first access to Home Assistant, you'll be prompted to create an admin account.

### 5. Enable HomeKit Integration

1. In Home Assistant, go to **Settings → Devices & Services**
2. Click **Add Integration** and search for "HomeKit"
3. Follow the setup wizard
4. Open the Home app on your iOS device and scan the QR code
5. Add your devices to HomeKit

## Management Commands

```bash
# Start Home Assistant
docker compose up -d

# Stop Home Assistant
docker compose down

# View logs
docker compose logs -f homeassistant

# Restart Home Assistant
docker compose restart homeassistant

# Rebuild after changes
docker compose up -d --build

# Check status
docker compose ps
```

## Configuration

### Environment Variables
- Copy `.env.example` to `.env` to customize settings
- Configure hostnames for services
- Set timezone

### Home Assistant
- Configuration files are stored in `./homeassistant/`
- Edit `configuration.yaml` for advanced settings
- Install integrations via the UI at **Settings → Devices & Services**
- Create automations via the UI or in `automations.yaml`
- Customize dashboards in the Lovelace editor
- Logs available through Docker Compose or the UI

### Traefik
- Access dashboard at port 8080 to monitor routes
- Automatic service discovery via Docker labels
- Configuration can be extended via static files in `./traefik/` (optional)

## Ports

- **80**: HTTP (Traefik)
- **443**: HTTPS (Traefik)
- **8080**: Traefik Dashboard
- **8123**: Home Assistant UI (via Traefik reverse proxy)

## Features

### Home Assistant
- Full-featured home automation platform
- Integrates with 2000+ devices and services
- Powerful automation engine with visual editor
- Built-in HomeKit integration
- Support for Zigbee, Z-Wave, Bluetooth, and more
- Voice control via Alexa, Google Assistant, and Siri (via HomeKit)
- Custom dashboards and mobile app

### Traefik Reverse Proxy
- Automatic reverse proxy and load balancer
- HTTP to HTTPS redirect support
- Docker service discovery
- Dashboard for monitoring routes and services
- Easy SSL/TLS certificate management (can be configured with Let's Encrypt)
- Routes traffic to Home Assistant and future services

## Troubleshooting

### Can't access the UI
- Ensure containers are running: `docker compose ps`
- Check logs: `docker compose logs -f homeassistant` or `docker compose logs -f traefik`
- Verify firewall settings allow ports 80, 443, 8080, and 8123
- Check Traefik dashboard at port 8080 to see if routes are registered

### Traefik not routing traffic
- Verify Docker labels are correct in `docker-compose.yml`
- Check Traefik dashboard to see registered routes
- Ensure services are on the correct Docker network
- View Traefik logs: `docker compose logs -f traefik`

### HomeKit pairing issues
- Ensure your iOS device is on the same network as the Raspberry Pi
- Remove and re-add the HomeKit integration if needed
- Try restarting the container: `docker compose restart homeassistant`
- Check the HomeKit QR code in **Settings → Devices & Services → HomeKit**

### USB device not detected
- Check device is connected: `ls -l /dev/tty*`
- Verify device permissions
- Try the alternative device path in `docker-compose.yml`

### Permission errors
- Ensure you've rebooted after running `setup.sh`
- Verify your user is in the docker group: `groups $USER`

## Backup

To backup your Home Assistant configuration:

```bash
tar -czf homeassistant-backup-$(date +%Y%m%d).tar.gz homeassistant/
```

To restore:

```bash
tar -xzf homeassistant-backup-YYYYMMDD.tar.gz
```

You can also use Home Assistant's built-in backup feature via the UI.

## Updates

To update Home Assistant to the latest version:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Popular Integrations

- **HomeKit**: Expose devices to Apple Home
- **Zigbee (ZHA)**: Connect Zigbee devices
- **Z-Wave**: Connect Z-Wave devices
- **MQTT**: Connect IoT devices
- **Philips Hue**: Smart lighting
- **Google Cast**: Chromecast devices
- **Spotify**: Music control
- **Weather**: Weather forecasts
- **Mobile App**: iOS/Android companion app

## Additional Guides

- [Cloudflare DNS Setup](./CLOUDFLARE_SETUP.md) - Configure Let's Encrypt with Cloudflare DNS challenge
- [DNS Configuration Explanation](./DNS_SETUP.md) - Understanding your DNS setup with Cloudflare
- [TP-Link Deco Port Forwarding](./DECO_PORT_FORWARDING.md) - Set up port forwarding on Deco routers

## Support

- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [Home Assistant Community](https://community.home-assistant.io/)
- [Integration List](https://www.home-assistant.io/integrations/)
