# #!/bin/bash

# # Define variables
# mkdir -p "$HOME_DIR/cardano-testnet"
# HOME_DIR="$HOME/cardano-testnet"
# CONFIG_URL="https://book.world.dev.cardano.org/environments/preprod"

# echo "Setting up Cardano Relay Node..."

# # Create necessary directories
# mkdir -p "$HOME_DIR/db"

# # Download configuration files
# echo "Downloading configuration files..."
# curl -O -J "$CONFIG_URL/config.json" -o "$HOME_DIR/config.json"
# curl -O -J "$CONFIG_URL/topology.json" -o "$HOME_DIR/topology.json"
# curl -O -J "$CONFIG_URL/byron-genesis.json" -o "$HOME_DIR/byron-genesis.json"
# curl -O -J "$CONFIG_URL/shelley-genesis.json" -o "$HOME_DIR/shelley-genesis.json"
# curl -O -J "$CONFIG_URL/alonzo-genesis.json" -o "$HOME_DIR/alonzo-genesis.json"
# curl -O -J "$CONFIG_URL/conway-genesis.json" -o "$HOME_DIR/conway-genesis.json"

# # Create the startTestNode.sh script
# echo "Creating startTestNode.sh script..."
# cat <<EOL > "$HOME_DIR/startTestNode.sh"
# #!/bin/bash
# PORT=6000
# HOSTADDR=0.0.0.0
# TOPOLOGY=$HOME_DIR/topology.json
# DB_PATH=$HOME_DIR/db
# SOCKET_PATH=$HOME_DIR/db/socket
# CONFIG=$HOME_DIR/config.json

# /usr/local/bin/cardano-node run \\
#   --topology \${TOPOLOGY} \\
#   --database-path \${DB_PATH} \\
#   --socket-path \${SOCKET_PATH} \\
#   --host-addr \${HOSTADDR} \\
#   --port \${PORT} \\
#   --config \${CONFIG}
# EOL
# chmod +x "$HOME_DIR/startTestNode.sh"

# # Create systemd service file
# echo "Creating cardano-testnode.service..."
# SERVICE_FILE="/etc/systemd/system/cardano-testnode.service"
# cat <<EOL | sudo tee $SERVICE_FILE
# [Unit]
# Description=Cardano TestNode Service
# Wants=network-online.target
# After=network-online.target

# [Service]
# User=$USER
# Type=simple
# WorkingDirectory=$HOME_DIR
# ExecStart=/bin/bash -c '$HOME_DIR/startTestNode.sh'
# ExecReload=pkill -HUP cardano-node
# KillSignal=SIGINT
# RestartKillSignal=SIGINT
# TimeoutStopSec=300
# LimitNOFILE=32768
# Restart=always
# RestartSec=5
# SyslogIdentifier=cardano-testnode

# [Install]
# WantedBy=multi-user.target
# EOL
# sudo chmod 644 $SERVICE_FILE

# # Enable and start the service
# echo "Reloading systemd, enabling and starting the cardano-testnode service..."
# sudo systemctl daemon-reload
# sudo systemctl enable cardano-testnode.service
# sudo systemctl start cardano-testnode.service

# # Show logs for verification
# echo "Setup complete. Displaying logs..."
# journalctl --unit=cardano-testnode --follow
