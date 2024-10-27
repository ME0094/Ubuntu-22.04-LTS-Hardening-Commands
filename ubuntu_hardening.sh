#!/bin/bash

# Ubuntu 22.04 LTS Hardening Script

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# 1. System Updates
apt update
apt upgrade -y
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades

# 2. User Management
sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t10/' /etc/login.defs
sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t7/' /etc/login.defs

apt install libpam-pwquality -y
sed -i '1s/^/password requisite pam_pwquality.so retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1\n/' /etc/pam.d/common-password

# 3. Network Security
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

systemctl disable avahi-daemon
systemctl disable cups
systemctl disable rpcbind

# 4. File System Security
chmod 700 /boot /etc/cron.monthly /etc/cron.weekly /etc/cron.daily /etc/cron.hourly
chmod 600 /etc/crontab /etc/ssh/sshd_config
chmod 644 /etc/passwd
chmod 640 /etc/shadow
chmod 644 /etc/group
chmod 640 /etc/gshadow

echo "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab

# 5. Secure SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
systemctl restart ssh

# 6. Install and Configure fail2ban
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# 7. Remove Unnecessary Packages
apt remove telnet rsh-client rsh-redone-client -y

# 8. Enable and Configure auditd
apt install auditd -y
systemctl enable auditd
systemctl start auditd

# 9. Disable USB Storage
echo "install usb-storage /bin/true" >> /etc/modprobe.d/disable-usb-storage.conf

# 10. Secure Shared Memory
echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab

echo "Hardening complete. Please review changes and reboot the system."
