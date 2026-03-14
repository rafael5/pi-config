#!/bin/bash

# Path to your public key
PUBKEY_FILE="$HOME/.ssh/id_ed25519.pub"

if [ ! -f "$PUBKEY_FILE" ]; then
  echo "Public key not found. Generate it first."
  exit 1
fi

PUBKEY=$(cat "$PUBKEY_FILE")
read -p "Enter a title for this SSH key (e.g., Pi5): " TITLE
read -s -p "Enter your GitHub Personal Access Token: " TOKEN
echo

# Upload SSH key using GitHub REST API
curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/keys \
  -d "{\"title\":\"$TITLE\",\"key\":\"$PUBKEY\"}"

echo
echo "Done."
