#!/bin/bash



# Function to check if a command exists
function command_exists() {
  command -v "$1" &>/dev/null
}


echo "Updating and upgrading the system..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y build-essential gcc clang

echo "Installing required dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install automake build-essential curl pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf -y


sudo apt-get install libtool
sudo apt-get install autoconf
ghcup_version=$(ghcup --version)
echo "GHCup version: ${ghcup_version}"

# Install GHCup if not already installed
if ! command_exists ghcup; then
  echo "Installing GHCup..."
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
else
  echo "GHCup is already installed."
  GHCup_version=$(ghcup --version)
  echo "Installed GHCup version: ${GHCup_version}"
fi

# Apply GHCup environment variables
echo "Applying GHCup environment variables..."
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
else
  echo "Warning: .bashrc not found. Ensure GHCup environment variables are set."
fi

# Verify GHCup installation
echo "Verifying GHCup installation..."
if command_exists ghcup; then
  echo "GHCup installed successfully."
else
  echo "GHCup installation failed. Please check the logs and try again."
  exit 1
fi

echo "Verifying GHC installation..."
echo "Installing and setting GHC version 8.10.7..."
ghcup install ghc 8.10.7
ghcup set ghc 8.10.7
echo "GHC version 8.10.7 installed and set successfully."


wait
echo "Verifying Cabal installation..."
echo "Installing and setting Cabal version 3.8.1.0..."
ghcup install cabal 3.8.1.0
ghcup set cabal 3.8.1.0
echo "Cabal version 3.8.1.0 installed and set successfully."

source ~/.bashrc

# Run the Cardano setup script
bash ./cardano-setup.sh


echo "Setup completed successfully."
exit 0