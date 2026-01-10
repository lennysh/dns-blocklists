# lennysh-blocklists

[![Update Blocklists](https://github.com/lennysh/lennysh-blocklists/actions/workflows/update-blocklists.yml/badge.svg)](https://github.com/lennysh/lennysh-blocklists/actions/workflows/update-blocklists.yml)

Per-service DNS blocklists generated from the [AdGuard Hostlists Registry](https://github.com/AdguardTeam/HostlistsRegistry). Block individual services like TikTok, Discord, or gaming platforms at the DNS level.

**🔄 Automatically updated daily via GitHub Actions**

## What This Is

This repository contains **individual filter files for 127+ online services** — each in its own `.txt` file. Instead of using a single massive blocklist, you can selectively block only the services you want.

Perfect for:
- **Parental controls** — Block specific social media or gaming services
- **Network management** — Restrict certain apps on IoT or guest networks
- **Focus/productivity** — Block distracting services during work hours
- **Privacy** — Block telemetry and tracking from specific platforms

## Available Blocklists

| Category | Services |
|----------|----------|
| **Social Media** | Discord, Facebook, Instagram, TikTok, Twitter/X, Snapchat, Reddit, LinkedIn, WhatsApp, Telegram, Signal, Bluesky, Mastodon, and more |
| **Streaming** | Netflix, YouTube, Twitch, Hulu, Disney+, HBO Max, Spotify, Amazon Streaming, Apple Streaming, Crunchyroll, and more |
| **Gaming** | Steam, Epic Games, PlayStation, Xbox Live, Nintendo, Roblox, Minecraft, League of Legends, Valorant, and more |
| **AI Services** | ChatGPT, Claude, DeepSeek, Perplexity |
| **Shopping** | Amazon, eBay, AliExpress, Shein, Temu, Shopee, Mercado Libre |
| **Gambling** | Betway, Betfair, Betano, Blaze |
| **Other** | iCloud Private Relay, Cloudflare, Plex, Box, Dropbox, and many more |

**[Browse all 127+ filter files →](service-filters/)**

## Usage

### Direct URL (Recommended)

Use raw GitHub URLs to subscribe to blocklists in your DNS server:

```
https://raw.githubusercontent.com/lennysh/lennysh-blocklists/main/service-filters/{service}.txt
```

**Example URLs:**
```
https://raw.githubusercontent.com/lennysh/lennysh-blocklists/main/service-filters/tiktok.txt
https://raw.githubusercontent.com/lennysh/lennysh-blocklists/main/service-filters/discord.txt
https://raw.githubusercontent.com/lennysh/lennysh-blocklists/main/service-filters/instagram.txt
```

### AdGuard Home

1. Go to **Filters** → **DNS blocklists**
2. Click **Add blocklist** → **Add a custom list**
3. Enter a name and paste the raw URL
4. Click **Save**

### Pi-hole

1. Go to **Adlists** in the web interface
2. Add the raw URL to a filter file
3. Run `pihole -g` to update gravity

### Technitium DNS Server

1. Go to **Apps** → **Advanced Blocking**
2. Add the raw URL as a blocklist
3. Apply changes

## Regenerating Filters

The filter files are generated from AdGuard's official [services.json](https://adguardteam.github.io/HostlistsRegistry/assets/services.json). To regenerate with the latest rules:

```bash
# Requires: curl, jq, bash
./generate-service-filters.sh
```

This will:
1. Download the latest `services.json` from AdGuard
2. Parse each service and extract its blocking rules
3. Generate individual `.txt` files in `service-filters/`

## Filter File Format

Each filter file includes:
- Header with service name, description, and generation timestamp
- AdGuard-compatible filter rules (works with most DNS blockers)

**Example (`tiktok.txt`):**
```
! Title: TikTok Block List
! Description: AdGuard filter rules for blocking TikTok
! Source: AdGuard Hostlists Registry
! Service ID: tiktok
! Generated: 2026-01-10 15:30:00 UTC
!
! This filter blocks domains related to TikTok
! Rules are sourced from: https://adguardteam.github.io/HostlistsRegistry/assets/services.json
!

||tiktok.com^
||tiktokcdn.com^
||tiktokv.com^
... (more rules)
```

## Updates

Filter files are **automatically updated daily at 6:00 AM UTC** via GitHub Actions. The workflow:

1. Downloads the latest `services.json` from AdGuard
2. Regenerates all filter files
3. Commits changes only if there are updates

You can also [manually trigger an update](../../actions/workflows/update-blocklists.yml) from the Actions tab.

Star/watch this repo to stay notified of changes.

## Related Projects

- [AdGuard Hostlists Registry](https://github.com/AdguardTeam/HostlistsRegistry) — Source of service definitions
- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) — Network-wide DNS ad blocker
- [Technitium DNS Server](https://github.com/TechnitiumSoftware/DnsServer) — Self-hosted DNS server

## License

Filter rules are sourced from [AdGuard Hostlists Registry](https://github.com/AdguardTeam/HostlistsRegistry) under their respective license. The generation script and this repository structure are provided as-is for personal and educational use.

---

**Questions or suggestions?** Open an issue on GitHub.

