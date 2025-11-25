#!/usr/bin/env bash
#
# configure-claude-plugin-git-creds.sh
#
# Configure Git to use HTTPS + PAT ONLY for:
#   https://github.com/DragonAngel1st/ClaudeCodePydanticSubagentFactory_plugin.git
#
# NOTE:
# - This stores the PAT in plaintext in ~/.git-credentials (Git's standard behavior).
# - PATs can expire. If cloning starts failing again, contact Patrick Miron (GitHub: DragonAngel1st)
#   to obtain a fresh PAT.

set -euo pipefail

REPO_OWNER="DragonAngel1st"
REPO_NAME="ClaudeCodePydanticSubagentFactory_plugin"
CRED_FILE="${HOME}/.git-credentials"

echo "============================================================"
echo " Git credential setup for Claude Code plugin repository"
echo " Repo: https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
echo "============================================================"
echo
echo "WARNING:"
echo "  This will store a GitHub Personal Access Token (PAT) in plaintext"
echo "  in ${CRED_FILE} using Git's 'credential.helper store'."
echo
echo "  PATs can expire or be revoked. If authentication fails later,"
echo "  please contact Patrick Miron (GitHub: DragonAngel1st) for a new PAT."
echo

read -p "Continue? (y/N): " CONFIRM
CONFIRM=${CONFIRM:-n}
if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
  echo "Aborting."
  exit 1
fi

echo
read -p "GitHub username: " GH_USER
read -s -p "GitHub PAT (will NOT be echoed): " GH_PAT
echo
echo

if [[ -z "${GH_USER}" || -z "${GH_PAT}" ]]; then
  echo "Error: username or PAT is empty. Aborting."
  exit 1
fi

echo "Configuring global Git credential helper and useHttpPath..."
git config --global credential.helper store
git config --global credential.useHttpPath true

# Backup existing credential file if it exists
if [[ -f "${CRED_FILE}" ]]; then
  BACKUP="${CRED_FILE}.bak.$(date +%s)"
  echo "Backing up existing ${CRED_FILE} to ${BACKUP}"
  cp "${CRED_FILE}" "${BACKUP}"

  # Remove any existing lines for this specific repo path
  tmp_file="${CRED_FILE}.tmp"
  grep -v "github.com/${REPO_OWNER}/${REPO_NAME}" "${CRED_FILE}" > "${tmp_file}" || true
  mv "${tmp_file}" "${CRED_FILE}"
fi

echo "Writing scoped credentials for this repo only..."
# NOTE: no .git suffix is needed here; useHttpPath=true will match path.
echo "https://${GH_USER}:${GH_PAT}@github.com/${REPO_OWNER}/${REPO_NAME}" >> "${CRED_FILE}"

echo
echo "Done."
echo
echo "You should now be able to clone this repo without prompts, e.g.:"
echo "  git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git /tmp/test-plugin"
echo
echo "If plugin installation in Claude Code starts failing again, your PAT"
echo "may have expired. Please contact Patrick Miron (DragonAngel1st) for renewal."
