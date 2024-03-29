#!/bin/bash

# Install Enable and start Apache
apt install apache2 -y
systemctl enable apache2
systemctl start apache2
sleep 5
wget -qO- http://localhost >/dev/null && echo "Apache is running" || echo "Apache is not running"
# Install Squid
apt install squid -y

# Enable firewall
sudo ufw enable
# Allow SSH on ens1
sudo ufw allow in on ens1 to any port 22
# Allow web traffic 80
sudo ufw allow http
# Allow web proxy port 3128 on the internet
sudo ufw allow 3128

# Remove existing network configuration files
varconfigold=$(find /etc/netplan -type f -name "*.yaml")
rm -rf $varconfigold
# Generate new network configuration
netplan generate
varconfignew=$(find /etc/netplan -type f -name "*.yaml")
echo "Config file found: $varconfignew"
# Define the network configuration
ADDRESS="192.168.16.21/24"
GATEWAY="192.168.16.2"
DNS_SERVER="192.168.16.2"
SEARCH_DOMAINS="home.arpa, localdomain"
ETH1=$(ip addr show eth1 | grep 'inet '| awk '{print $2}')
# Generate the configuration
cat << EOF | sudo tee $varconfignew
network:
    version: 2
    ethernets:
        eth0:
            addresses: [$ADDRESS]
            routes:
              - to: default
                via: $GATEWAY
            nameservers:
                addresses: [$DNS_SERVER]
                search: [$SEARCH_DOMAINS]
        eth1:
            addresses: [$ETH1]
EOF
chmod 600 $varconfignew
# Apply the new configuration
sudo netplan apply

# Update /etc/hosts
sudo sed -i '/server1/d' /etc/hosts
echo "$ADDRESS server1" | sudo tee -a /etc/hosts

# Create user accounts
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
for USER in ${USERS[@]}; do
    sudo useradd -m -s /bin/bash $USER
    sudo mkdir /home/$USER/.ssh
    sudo chown -R $USER:$USER /home/$USER/.ssh
    sudo chmod 700 /home/$USER/.ssh
    sudo touch /home/$USER/.ssh/authorized_keys
    # Add public key to dennis
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | 
    cat >> /home/$USER/.ssh/authorized_keys
    sudo chmod 600 /home/$USER/.ssh/authorized_keys
done

# Add dennis to sudoers
touch /etc/sudoers.d/dennis

# Add sudo access to dennis
echo "dennis ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/dennis

# Add dennis to sudo group (optional as dennis is already in sudo.d dir)
sudo usermod -aG sudo dennis
