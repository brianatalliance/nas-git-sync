#!/bin/bash
# GitHub → Synology NAS Git Sync Script
# Author:  Brian Vicente
# Version: 1.0.0
# Date:    2026-03-28
# Org:     Alliance for Empowerment
#
# Syncs all GitHub repositories from brianatalliance to /volume1/git/
# Designed to run as a Scheduled Task in DSM Task Scheduler.
#
# Setup:
#   1. SSH into NAS: ssh networkcoordinator@<NAS_IP> -p 2237
#   2. Create the directory: sudo mkdir -p /volume1/git && sudo chown networkcoordinator:users /volume1/git
#   3. Generate a GitHub PAT (classic) with 'repo' scope at:
#      https://github.com/settings/tokens
#   4. Save token: echo "YOUR_TOKEN" > /volume1/git/.gh-token && chmod 600 /volume1/git/.gh-token
#   5. Run this script once manually to do initial clone
#   6. Add to DSM Task Scheduler for automated sync

SYNC_DIR="/volume1/git"
LOG_FILE="${SYNC_DIR}/sync.log"
GH_USER="brianatalliance"
TOKEN_FILE="${SYNC_DIR}/.gh-token"

# All repositories to sync
REPOS=(
    "wireguard-vpn-spk"
    "perplexity-windows-xpc"
    "perplexity-xpc"
    "udm-nspawn-pki"
    "synology-connector"
    "perplexity-connector"
    "atera-connector"
    "atera-dashboard"
)

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "${LOG_FILE}"
}

# Check for token
if [ ! -f "${TOKEN_FILE}" ]; then
    log "[ERROR] GitHub token not found at ${TOKEN_FILE}"
    log "Create one at https://github.com/settings/tokens (classic, repo scope)"
    log "Then: echo 'ghp_yourtoken' > ${TOKEN_FILE} && chmod 600 ${TOKEN_FILE}"
    exit 1
fi

GH_TOKEN=$(cat "${TOKEN_FILE}" | tr -d '[:space:]')

if [ -z "${GH_TOKEN}" ]; then
    log "[ERROR] GitHub token is empty"
    exit 1
fi

# Ensure sync directory exists
mkdir -p "${SYNC_DIR}"

log "========================================="
log "GitHub Sync Starting"
log "========================================="

SUCCESS=0
FAILED=0

for REPO in "${REPOS[@]}"; do
    REPO_DIR="${SYNC_DIR}/${REPO}"
    REPO_URL="https://${GH_TOKEN}@github.com/${GH_USER}/${REPO}.git"

    if [ -d "${REPO_DIR}/.git" ]; then
        # Repo exists — pull latest
        log "[PULL] ${REPO}"
        cd "${REPO_DIR}"
        git remote set-url origin "${REPO_URL}" 2>/dev/null
        OUTPUT=$(git pull --ff-only 2>&1)
        RC=$?
        if [ $RC -eq 0 ]; then
            if echo "${OUTPUT}" | grep -q "Already up to date"; then
                log "  ✓ ${REPO} — up to date"
            else
                log "  ✓ ${REPO} — updated"
            fi
            SUCCESS=$((SUCCESS + 1))
        else
            log "  ✗ ${REPO} — pull failed: ${OUTPUT}"
            FAILED=$((FAILED + 1))
        fi
    else
        # Repo doesn't exist — clone
        log "[CLONE] ${REPO}"
        OUTPUT=$(git clone "${REPO_URL}" "${REPO_DIR}" 2>&1)
        RC=$?
        if [ $RC -eq 0 ]; then
            log "  ✓ ${REPO} — cloned"
            SUCCESS=$((SUCCESS + 1))
        else
            log "  ✗ ${REPO} — clone failed: ${OUTPUT}"
            FAILED=$((FAILED + 1))
        fi
    fi
done

log "-----------------------------------------"
log "Sync complete: ${SUCCESS} OK, ${FAILED} failed (${#REPOS[@]} total)"
log "========================================="

exit 0
