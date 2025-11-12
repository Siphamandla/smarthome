# TP-Link Deco Port Forwarding Setup

This guide will help you set up port forwarding on your TP-Link Deco router to expose your Raspberry Pi services to the internet.

## Prerequisites

- TP-Link Deco app installed on your phone
- Connected to your Deco network
- Raspberry Pi IP address: `192.168.68.122`

## Steps

### 1. Open Deco App

Launch the Deco app on your phone.

### 2. Navigate to Port Forwarding

- Tap **More** (bottom right corner)
- Tap **Advanced**
- Tap **Port Forwarding**

### 3. Add HTTP Port Forwarding Rule

1. Tap the **"+"** button to add a new rule
2. Configure the following:
   - **Device**: Select your Raspberry Pi from the list (or manually enter `192.168.68.122`)
   - **External Port**: `80`
   - **Internal Port**: `80`
   - **Protocol**: `TCP`
3. Tap **Save**

### 4. Add HTTPS Port Forwarding Rule

1. Tap the **"+"** button again
2. Configure the following:
   - **Device**: Select your Raspberry Pi (or enter `192.168.68.122`)
   - **External Port**: `443`
   - **Internal Port**: `443`
   - **Protocol**: `TCP`
3. Tap **Save**

### 5. Enable the Rules

- Make sure both rules are toggled **ON** (enabled)
- The app will apply the changes automatically

### 6. Test the Configuration

Wait 1-2 minutes for the changes to take effect, then test:

```bash
# Test HTTP
curl http://pi.metrofleet.co.za/api/v1/health

# Test HTTPS (after Let's Encrypt certificate is issued)
curl https://pi.metrofleet.co.za/api/v1/health
```

## Port Forwarding Rules Summary

| Service | External Port | Internal IP | Internal Port | Protocol |
|---------|--------------|-------------|---------------|----------|
| HTTP    | 80           | 192.168.68.122 | 80            | TCP      |
| HTTPS   | 443          | 192.168.68.122 | 443           | TCP      |

## Troubleshooting

### Pi not showing in device list

If your Raspberry Pi doesn't appear in the device list:
- Manually enter the IP address: `192.168.68.122`
- Make sure the Pi is connected to the Deco network
- Check the Pi's IP hasn't changed (run `hostname -I` on the Pi)

### Connection still fails after setup

1. **Verify rules are enabled** in the Deco app
2. **Check Traefik is running** on the Pi:
   ```bash
   ssh pi@192.168.68.122
   docker ps | grep traefik
   ```
3. **Test from outside your network** (use mobile data, not WiFi)
4. **Check Cloudflare proxy is disabled** (gray cloud, not orange)

### ISP blocking ports

Some ISPs block port 80/443 for residential connections. If port forwarding doesn't work:
- Contact VOX support to check if ports are blocked
- Consider using Cloudflare Tunnel as an alternative (no port forwarding needed)

## Next Steps

Once port forwarding is working:
1. Let's Encrypt will automatically issue SSL certificates via Cloudflare DNS challenge
2. Your API will be accessible at `https://pi.metrofleet.co.za`
3. Certificates will auto-renew every 90 days

## Security Note

⚠️ **Important:** You're exposing your Pi to the internet. Make sure:
- Traefik is properly configured with secure routes
- Your API has authentication/authorization
- Keep your Pi and services updated
- Monitor logs for suspicious activity
