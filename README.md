# NAS Git Sync

**Author:** Brian Vicente
**Version:** 1.0.0
**Date:** 2026-03-28
**Org:** Alliance for Empowerment

Automated sync script that mirrors all GitHub repositories from `brianatalliance` to `/volume1/git/` on a Synology NAS.

## Repositories Synced

| Repository | Description |
|-----------|-------------|
| `wireguard-vpn-spk` | WireGuard VPN Tunnel SPK for Synology DS220+ |
| `perplexity-windows-xpc` | Perplexity AI Windows integration (Summon-Aunties) |
| `perplexity-xpc` | PerplexityXPC broker service and tray app |
| `udm-nspawn-pki` | UDM Pro two-tier PKI in systemd-nspawn |
| `synology-connector` | Synology DSM Web API connector |
| `perplexity-connector` | Perplexity Sonar API connector |
| `atera-connector` | Atera RMM API v3 connector |
| `atera-dashboard` | Atera NOC dashboard (React) |

## Setup

```bash
# 1. SSH into the NAS
ssh networkcoordinator@<NAS_IP> -p 2237

# 2. Create the git directory
sudo mkdir -p /volume1/git
sudo chown networkcoordinator:users /volume1/git

# 3. Generate a GitHub PAT at https://github.com/settings/tokens
#    Select: Classic token → repo scope
#    Save the token:
echo "ghp_yourtoken" > /volume1/git/.gh-token
chmod 600 /volume1/git/.gh-token

# 4. Download the sync script
curl -sL https://raw.githubusercontent.com/brianatalliance/nas-git-sync/master/git-sync-nas.sh \
    -o /volume1/git/git-sync-nas.sh
chmod +x /volume1/git/git-sync-nas.sh

# 5. Run initial sync
bash /volume1/git/git-sync-nas.sh

# 6. Add to DSM Task Scheduler
#    Control Panel → Task Scheduler → Create → Scheduled Task → User-defined script
#    User: root
#    Schedule: Daily at 2:00 AM (or your preference)
#    Script: bash /volume1/git/git-sync-nas.sh
```

## Log

Sync logs are written to `/volume1/git/sync.log`.

## License

MIT
