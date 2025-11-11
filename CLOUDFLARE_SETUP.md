# Cloudflare DNS Challenge Setup

This guide will help you set up Cloudflare DNS challenge for Let's Encrypt certificates (no port forwarding needed).

## Prerequisites

- Domain name (`metrofleet.co.za`) managed by Cloudflare
- Cloudflare account

## Step 1: Get Cloudflare API Token

1. **Log in to Cloudflare Dashboard**: https://dash.cloudflare.com

2. **Go to API Tokens**:
   - Click your profile icon (top right)
   - Select "My Profile"
   - Click "API Tokens" in the left menu

3. **Create Token**:
   - Click "Create Token"
   - Use the "Edit zone DNS" template (or create custom token)

4. **Configure Token Permissions**:
   - **Permissions** section:
     - Click "+ Add more"
     - First permission: Select `Zone` → `DNS` → `Edit`
     - Click "+ Add more" again
     - Second permission: Select `Zone` → `Zone` → `Read`
   
   - **Zone Resources** section:
     - Look for the dropdown that says "All zones from an account"
     - Click it and select "Specific zone"
     - In the text field that appears, type or select `metrofleet.co.za`
     - (If using the "Edit zone DNS" template, this might already be set correctly)
   
   - **Client IP Address Filtering**: (optional) Leave as "All IPs" or restrict to your Pi's public IP
   - **TTL**: (optional) Set token expiration if desired, or leave as default

5. **Create and Copy Token**:
   - Click "Continue to summary"
   - Click "Create Token"
   - **IMPORTANT**: Copy the token immediately (you can't see it again!)

## Step 2: Update Configuration

1. **Edit `.env` file** on your Pi:
   ```bash
   cd ~/Projects/smarthome
   nano .env
   ```

2. **Replace the placeholder** with your actual token:
   ```properties
   CF_API_EMAIL=support@metrofleet.co.za
   CF_DNS_API_TOKEN=your-actual-cloudflare-token-here
   ```

3. **Save and exit**: `Ctrl+X`, then `Y`, then `Enter`

## Step 3: Rebuild Traefik

Run the setup script option 4:
```bash
./setup.sh
# Select option 4: Prepare Traefik (ACME + Rebuild)
```

Or manually:
```bash
docker compose stop traefik
docker compose rm -f traefik
docker compose build --no-cache traefik
docker compose up -d traefik
```

## Step 4: Monitor Certificate Issuance

Watch Traefik logs for DNS challenge:
```bash
docker logs -f traefik
```

You should see:
- `msg="Testing certificate renew..."`
- `msg=Register...`
- DNS challenge validation (no more timeout errors)
- Certificate successfully obtained

## Step 5: Verify HTTPS

Test your API endpoint:
```bash
curl https://pi.metrofleet.co.za/api/v1/health
```

You should get a valid response with a real SSL certificate (no `-k` flag needed).

## Benefits of DNS Challenge

✅ **No port forwarding required** (ports 80/443 can stay closed)  
✅ **Works behind firewalls** or with ISP port blocks  
✅ **Supports wildcard certificates** (e.g., `*.metrofleet.co.za`)  
✅ **More secure** - no need to expose services to the internet during validation  

## Troubleshooting

### "Invalid API Token"
- Verify token has correct permissions (DNS Edit + Zone Read)
- Check token hasn't expired
- Ensure zone is set to `metrofleet.co.za`

### "No such host"
- Verify DNS records exist in Cloudflare for `pi.metrofleet.co.za`
- Wait a few minutes for DNS propagation

### "Context deadline exceeded"
- Check Cloudflare API status: https://www.cloudflarestatus.com
- Verify Pi has internet connectivity: `ping 1.1.1.1`

## Security Note

🔒 **Keep your API token secret!**
- Never commit `.env` to git (already in `.gitignore`)
- Rotate tokens periodically
- Use minimal permissions (only DNS edit for specific zone)
