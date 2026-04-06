# NAS Git Sync

**Author:** Brian Vicente
**Version:** 1.1.0
**Date:** 2026-03-28
**Org:** Alliance for Empowerment

Automated sync script that mirrors GitHub repositories from `brianatalliance` to `/volume1/git/` on a Synology NAS.

## Repositories Synced

| Repository | Description |
|-----------|-------------|
| `brianatalliance` | GitHub profile README |
| `nas-git-sync` | This repo — automated GitHub → NAS sync script |
| `wireguard-vpn-spk` | WireGuard VPN Tunnel SPK for Synology DS220+ |
| `perplexity-windows-xpc` | Perplexity AI Windows integration (Summon-Aunties) |
| `perplexity-xpc` | PerplexityXPC broker service and tray app |
| `udm-nspawn-pki` | UDM Pro two-tier PKI in systemd-nspawn |
| `synology-connector` | Synology DSM Web API connector |
| `perplexity-connector` | Perplexity Sonar API connector |
| `atera-connector` | Atera RMM API v3 connector |
| `atera-dashboard` | Atera NOC dashboard (React) |

The repo list is configurable — see [Configuration](#configuration) below.

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

## Configuration

The script is fully configurable via environment variables and an optional config file — no hardcoded values need to be edited.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SYNC_DIR` | `/volume1/git` | Directory where repos are synced |
| `GH_USER` | `brianatalliance` | GitHub username to sync from |
| `TOKEN_FILE` | `${SYNC_DIR}/.gh-token` | Path to file containing GitHub PAT |
| `REPOS_CONF` | `${SYNC_DIR}/repos.conf` | Path to optional repo list config file |

### Custom Repo List

Create `/volume1/git/repos.conf` (one repository name per line) to override the default list:

```
# /volume1/git/repos.conf
# Lines starting with # are ignored
nas-git-sync
perplexity-connector
atera-connector
my-custom-repo
```

When `repos.conf` is present it is used exclusively. When absent, the built-in default list is used.

### Override via Environment

```bash
# Sync a different user's repos to a different path
SYNC_DIR=/mnt/backup GH_USER=otheruser bash git-sync-nas.sh

# Use a custom token file
TOKEN_FILE=/home/user/.secrets/github-token bash git-sync-nas.sh
```

## Log

Sync logs are written to `${SYNC_DIR}/sync.log` (default: `/volume1/git/sync.log`).

## Related Projects

- [perplexity-windows-xpc](https://github.com/brianatalliance/perplexity-windows-xpc) — Perplexity AI for Windows — PowerShell, system tray, Office integration
- [perplexity-xpc](https://github.com/brianatalliance/perplexity-xpc) — PerplexityXPC broker service, tray app, MCP server management
- [perplexity-connector](https://github.com/brianatalliance/perplexity-connector) — Perplexity Sonar API connector — CLI, streaming, async, structured output
- [atera-dashboard](https://github.com/brianatalliance/atera-dashboard) — Atera RMM NOC dashboard — React + Vite + Tailwind + Recharts
- [atera-connector](https://github.com/brianatalliance/atera-connector) — Atera RMM API v3 connector — Python CLI with full CRUD support
- [synology-connector](https://github.com/brianatalliance/synology-connector) — Synology DSM Web API connector — 40 CLI actions across 10 modules
- [udm-nspawn-pki](https://github.com/brianatalliance/udm-nspawn-pki) — Two-tier PKI in systemd-nspawn on UniFi Dream Machine Pro
- [wireguard-vpn-spk](https://github.com/brianatalliance/wireguard-vpn-spk) — WireGuard VPN Tunnel SPK for Synology DS220+ (userspace wireguard-go)

## Acknowledgments

- [Synology](https://www.synology.com/) — NAS platform and DSM Task Scheduler
- Git — distributed version control
- Bash — shell scripting environment

## Author

**Brian Vicente** — Network Coordinator & Cybersecurity Admin

Built with [Perplexity Computer](https://computer.perplexity.ai)

## License

MIT
