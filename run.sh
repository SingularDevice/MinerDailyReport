#!/bin/bash
# Prepares project structure and creates the service
echo "Creating directories..."
sudo mkdir -p /miner/downloads /miner/logs

echo "Moving scripts..."
sudo cp -r ./scripts /miner/
sudo cp ./Launcher.sh /miner/Launcher.sh

echo "Creating service..."
sudo cp ./launcher.service /etc/systemd/system/launcher.service
sudo systemctl enable launcher

echo "Starting service..."
sudo systemctl start launcher

echo "Script finished!"