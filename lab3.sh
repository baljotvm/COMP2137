#!/bin/bash

# This script automates the configuration of hosts by transferring and executing the configure-host.sh script on designated servers and updating the local /etc/hosts file

# Copy configure-host.sh to server1-mgmt
scp configure-host.sh baljot@server1-mgmt:/root

# Execute configure-host.sh on server1-mgmt
ssh baljot@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

# Copy configure-host.sh to server2-mgmt
scp configure-host.sh baljot@server2-mgmt:/root

# Execute configure-host.sh on server2-mgmt
ssh baljot@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

# Update the local /etc/hosts file
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
