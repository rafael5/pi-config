#!/bin/bash

set -e

echo "Updating system..."
sudo apt update

echo "Installing packages..."
sudo apt install -y watchdog unattended-upgrades logrotate curl

echo "Enabling hardware watchdog..."
sudo sed -i '$ a dtparam=watchdog=on' /boot/config.txt

sudo systemctl enable watchdog

echo "Enabling automatic updates..."
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

echo "Installing log2ram..."
if ! dpkg -l | grep -q log2ram; then
  curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zx
  cd log2ram-master
  chmod +x install.sh
  sudo ./install.sh
  cd ..
fi

echo "Creating monitoring scripts..."

sudo mkdir -p /usr/local/pi-tools

cat << 'EOF' | sudo tee /usr/local/pi-tools/health-check.sh
#!/bin/bash

LOG="/var/log/pi-health.log"

echo "---- $(date) ----" >> $LOG

df -h >> $LOG
free -h >> $LOG

if command -v vcgencmd > /dev/null
then
  vcgencmd measure_temp >> $LOG
fi

DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$DISK" -gt 95 ]; then
  echo "Disk critical reboot" >> $LOG
  reboot
fi
EOF

cat << 'EOF' | sudo tee /usr/local/pi-tools/network-watch.sh
#!/bin/bash

TARGET=8.8.8.8

ping -c 2 $TARGET > /dev/null

if [ $? != 0 ]; then
  systemctl restart dhcpcd
fi
EOF

cat << 'EOF' | sudo tee /usr/local/pi-tools/memory-watch.sh
#!/bin/bash

FREE=$(free | awk '/Mem:/ {print $4}')

if [ "$FREE" -lt 20000 ]; then
  reboot
fi
EOF

sudo chmod +x /usr/local/pi-tools/*.sh

echo "Installing cron jobs..."

CRON=$(mktemp)

crontab -l 2>/dev/null > $CRON || true

cat << 'EOF' >> $CRON
# Raspberry Pi uptime toolkit

0 * * * * /usr/local/pi-tools/health-check.sh
*/5 * * * * /usr/local/pi-tools/network-watch.sh
*/10 * * * * /usr/local/pi-tools/memory-watch.sh
0 3 * * 0 apt-get autoremove -y && apt-get clean
30 2 * * * /usr/sbin/logrotate /etc/logrotate.conf
EOF

crontab $CRON
rm $CRON

echo "Mounting temp directories in RAM..."

if ! grep -q "tmpfs /tmp" /etc/fstab
then
  echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0" | sudo tee -a /etc/fstab
fi

if ! grep -q "tmpfs /var/tmp" /etc/fstab
then
  echo "tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0" | sudo tee -a /etc/fstab
fi

echo "Toolkit installation complete."
echo "Reboot recommended."
