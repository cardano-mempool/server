#!/bin/bash

echo "Creating working directory for Cardano source code..."
mkdir -p $HOME/cardano-src
cd $HOME/cardano-src


SODIUM_VERSION=$(curl https://raw.githubusercontent.com/input-output-hk/iohk-nix/$IOHKNIX_VERSION/flake.lock | jq -r '.nodes.sodium.original.rev')
echo "Using sodium version: $SODIUM_VERSION"

echo "Downloading and compiling libsodium..."
git clone https://github.com/intersectmbo/libsodium
cd libsodium
git checkout $SODIUM_VERSION
./autogen.sh
./configure
make
make check
sudo make install

echo "Setting environment variables for libsodium..."
# Determine the shell profile file based on the shell application in use
if [ -n "$ZSH_VERSION" ]; then
  PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  PROFILE="$HOME/.bashrc"
else
  echo "Unsupported shell. Please use bash or zsh."
  exit 1
fi

# Variables to be added
LD_LIBRARY_PATH_ENTRY='export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"'
PKG_CONFIG_PATH_ENTRY='export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"'

# Add the variables to the shell profile if not already present
if ! grep -Fxq "$LD_LIBRARY_PATH_ENTRY" "$PROFILE"; then
  echo "$LD_LIBRARY_PATH_ENTRY" >> "$PROFILE"
  echo "Added LD_LIBRARY_PATH to $PROFILE."
else
  echo "LD_LIBRARY_PATH already exists in $PROFILE."
fi

if ! grep -Fxq "$PKG_CONFIG_PATH_ENTRY" "$PROFILE"; then
  echo "$PKG_CONFIG_PATH_ENTRY" >> "$PROFILE"
  echo "Added PKG_CONFIG_PATH to $PROFILE."
else
  echo "PKG_CONFIG_PATH already exists in $PROFILE."
fi

# Reload the shell profile
echo "Reloading $PROFILE..."
source "$PROFILE"
echo "Shell profile reloaded. Environment variables are now updated."

echo "Downloading and compiling libsecp256k1..."
cd $HOME/cardano-src
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
git checkout ac83be33
./autogen.sh
./configure --enable-module-schnorrsig --enable-experimental
make
make check
sudo make install
sudo ldconfig

echo "Downloading Cardano Node source code..."
cd $HOME/cardano-src
git clone https://github.com/IntersectMBO/cardano-node.git
cd cardano-node
git fetch --all --recurse-submodules --tags
git checkout $(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | jq -r .tag_name)


echo "Configuring the build options..."
cabal update
cabal configure --with-compiler=ghc
sudo apt install llvm-9
sudo apt install clang-9 libnuma-dev
sudo ln -s /usr/bin/llvm-config-9 /usr/bin/llvm-config
sudo ln -s /usr/bin/opt-9 /usr/bin/opt
sudo ln -s /usr/bin/llc-9 /usr/bin/llc
sudo ln -s /usr/bin/clang-9 /usr/bin/clang

echo "Building Cardano Node and CLI..."
cabal build cardano-node cardano-cli

echo "Installing Cardano Node and CLI binaries..."
mkdir -p $HOME/.local/bin
cp -p "$(./scripts/bin-path.sh cardano-node)" $HOME/.local/bin/
cp -p "$(./scripts/bin-path.sh cardano-cli)" $HOME/.local/bin/

echo "Cardano Node and CLI binaries installed successfully."

echo 'export PATH="$HOME/.local/bin/:$PATH"' >> $PROFILE
source $PROFILE

echo "Verifying Cardano CLI and Node installation..."
cardano_cli_version=$(cardano-cli --version)
cardano_node_version=$(cardano-node --version)

if [[ -n $cardano_cli_version && -n $cardano_node_version ]]; then
  echo "Cardano CLI and Node installed successfully."
else
  echo "Failed to install Cardano CLI or Node. Please check the logs."
  exit 1
fi

echo "Cardano setup completed successfully!"
