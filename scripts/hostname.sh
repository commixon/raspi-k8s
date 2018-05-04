#!/bin/sh

hostname=$1
ip=$2 # should be of format: 192.168.1.100
router=$3
dns=$4
interface=$5

interface="${interface:-eth0}"

# Change the hostname
sudo hostnamectl --transient set-hostname $hostname
sudo hostnamectl --static set-hostname $hostname
sudo hostnamectl --pretty set-hostname $hostname
sudo sed -i s/raspberrypi/$hostname/g /etc/hosts

# Set the static ip

sudo cat <<EOT >> /etc/dhcpcd.conf
interface $interface
static ip_address=$ip/24
static routers=$router
static domain_name_servers=$dns
EOT
