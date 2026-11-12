# 🌐 Cloud VPS Deployment Guide

Step-by-step instructions for deploying the **XM AI Scalping Bot** on a headless Linux cloud server for 24/7 unattended operation.

---

## Recommended VPS Specifications

| Resource | Minimum | Recommended |
|---|---|---|
| **CPU** | 2 vCPU | 4 vCPU |
| **RAM** | 4 GB | 8 GB |
| **Storage** | 20 GB SSD | 40 GB NVMe SSD |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS |
| **Network** | Low latency to broker server | < 10ms ping to broker datacenter |

### Suggested Providers
- **Hetzner Cloud** (Nuremberg/Helsinki) — Best value for European brokers
- **DigitalOcean** (NYC/LON) — Simple scaling, predictable pricing
- **AWS EC2** (`t3.medium`) — Enterprise-grade, global edge locations
- **Vultr** (Tokyo/Singapore) — Optimal for Asian session scalping

---

## Option A: Native Installation (Recommended)

```bash
# 1. SSH into your VPS
ssh root@your-server-ip

# 2. Clone the repository
git clone https://github.com/mt-abdulla-it/xm-ai-scalping-bot.git
cd xm-ai-scalping-bot

# 3. Run automated installer (installs Wine, Xvfb, MT5, Python deps)
make install

# 4. Start virtual framebuffer for headless GUI
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# 5. Launch MetaTrader 5
make run

# 6. (Optional) Enable VNC for remote visual monitoring
x11vnc -display :99 -forever -nopw &
# Connect via VNC client to your-server-ip:5900
```

---

## Option B: Docker Deployment

```bash
# 1. Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh

# 2. Clone and deploy
git clone https://github.com/mt-abdulla-it/xm-ai-scalping-bot.git
cd xm-ai-scalping-bot
make docker-up

# 3. Monitor logs
docker logs -f xm-ai-scalping-bot

# 4. Stop the stack
make docker-down
```

---

## Keeping It Running 24/7

### Using systemd (Native Install)

Create a service file at `/etc/systemd/system/xm-scalper.service`:

```ini
[Unit]
Description=XM AI Scalping Bot - MetaTrader 5
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/xm-ai-scalping-bot
Environment=DISPLAY=:99
ExecStartPre=/usr/bin/Xvfb :99 -screen 0 1920x1080x24 &
ExecStart=/usr/bin/wine "/root/.wine/drive_c/Program Files/XM Global MT5/terminal64.exe"
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

Then enable and start:

```bash
sudo systemctl enable xm-scalper
sudo systemctl start xm-scalper
sudo systemctl status xm-scalper
```

---

## Monitoring & Alerts

Check bot status and trade progress remotely:

```bash
# SSH in and run:
cd xm-ai-scalping-bot
make status
make dashboard
```

For automated alerts, consider connecting the `export_dashboard.py` output to a Telegram Bot or email notification script via cron.
