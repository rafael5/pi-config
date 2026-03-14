#!/bin/bash

# ==============================
# GitHub SSH Setup Script (SSH-only)
# ==============================

# Step 1: Check if SSH key exists, create if not
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "your_email@example.com" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "SSH key already exists."
fi

# Step 2: Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

# Step 3: Display public key for GitHub
PUBKEY=$(cat "$HOME/.ssh/id_ed25519.pub")
echo
echo "Copy this public key and add it to GitHub:"
echo "$PUBKEY"
echo
echo "Go to: https://github.com/settings/ssh/new to add the key."
echo

# Step 4: Set SSH remote for your repo
read -p "Enter path to your git repo (default: current directory): " repo_path
repo_path=${repo_path:-$(pwd)}
cd "$repo_path" || { echo "Invalid path"; exit 1; }

read -p "Enter your GitHub username: " GH_USER
read -p "Enter your repository name: " GH_REPO

ssh_remote="git@github.com:${GH_USER}/${GH_REPO}.git"
git remote set-url origin "$ssh_remote"

echo "Remote changed to SSH: $ssh_remote"
echo "Setup complete! Now you can git push without using a password."
