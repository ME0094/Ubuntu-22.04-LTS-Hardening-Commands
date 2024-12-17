# Ubuntu 22.04 LTS Hardening Guide

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-22.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu 22.04 LTS">
  <img src="https://img.shields.io/badge/Security-Hardening-blue?style=for-the-badge&logo=shield&logoColor=white" alt="Security Hardening">
  <img alt="License" src="https://img.shields.io/github/license/ME0094/Ubuntu-22.04-LTS-Hardening-Commands?style=for-the-badge"/>
</p>

## Table of Contents
1. [Introduction](#introduction)
2. [Security Considerations](#security-considerations)
3. [Prerequisites](#prerequisites)
4. [Hardening Steps](#hardening-steps)
   1. [System Updates](#1-system-updates)
   2. [User Management](#2-user-management)
   3. [Network Security](#3-network-security)
   4. [File System Security](#4-file-system-security)
   5. [Secure SSH](#5-secure-ssh)
   6. [Install and Configure fail2ban](#6-install-and-configure-fail2ban)
   7. [Remove Unnecessary Packages](#7-remove-unnecessary-packages)
   8. [Enable and Configure auditd](#8-enable-and-configure-auditd)
   9. [Disable USB Storage](#9-disable-usb-storage)
   10. [Secure Shared Memory](#10-secure-shared-memory)
5. [Post-Hardening Steps](#post-hardening-steps)
6. [Validation and Testing](#validation-and-testing)
7. [Troubleshooting](#troubleshooting)
8. [Contributing](#contributing)
9. [Reporting Security Vulnerabilities](#reporting-security-vulnerabilities)
10. [Disclaimer](#disclaimer)
11. [License](#license)

## Introduction
Welcome to the Ubuntu 22.04 LTS Hardening Guide!

This comprehensive resource provides a set of carefully curated commands and instructions designed to significantly enhance the security posture of your Ubuntu 22.04 LTS system. By implementing these hardening measures, you can effectively reduce your system's attack surface and bolster its overall security.

This guide is ideal for system administrators, security professionals, and enthusiasts who want to ensure their Ubuntu systems are configured with industry-standard security best practices. Whether you're securing a personal workstation or hardening a production server, these steps will help you establish a robust security baseline.

## Security Considerations
Before proceeding with the hardening process, please keep the following important points in mind:

- **Testing Environment:** Always test these commands in a non-production environment first to ensure compatibility with your specific setup.
- **Command Understanding:** Take the time to understand the implications of each command before execution. Some changes may impact system functionality.
- **Regular Updates:** Security is an ongoing process. Regularly update and review your security measures to stay protected against new threats.
- **Customization:** While these steps provide a solid security baseline, additional measures may be necessary depending on your specific use case and threat model.
- **Backup:** Always create a full system backup before making significant changes to your system configuration.

## Prerequisites
Ensure you have the following before starting the hardening process:

- A fresh installation of Ubuntu 22.04 LTS
- Root or sudo access to the system
- Basic knowledge of Linux command line operations
- A complete backup of important data (strongly recommended)
- A secure network connection for downloading updates and packages

## Automated Hardening Script
For your convenience, I've provided an automated script that applies all the hardening steps. To use it:

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/ME0094/Ubuntu-22.04-LTS-Hardening-Commands/main/ubuntu_hardening.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x ubuntu_hardening.sh
   ```

3. Run the script with root privileges:
   ```bash
   sudo ./ubuntu_hardening.sh
   ```

**Note:** Always review the script and understand its actions before running it on your system.

## Manual Hardening Steps
If you prefer to apply the hardening measures manually, follow these steps:


### 1. System Updates
Keeping your system up-to-date is crucial for security. This step ensures you have the latest security patches and bug fixes.

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

**Explanation:**
- `apt update`: Refreshes the package list
- `apt upgrade`: Installs available updates
- `unattended-upgrades`: Enables automatic security updates
- `dpkg-reconfigure`: Configures unattended-upgrades interactively

### 2. User Management
Enhance password policies to enforce stronger authentication:

```bash
sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t10/' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t7/' /etc/login.defs

sudo apt install libpam-pwquality -y
sudo sed -i '1s/^/password requisite pam_pwquality.so retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1\n/' /etc/pam.d/common-password
```

**Explanation:**
- Sets maximum password age to 90 days
- Sets minimum password age to 10 days
- Installs and configures password quality checking library
- Enforces password complexity requirements

### 3. Network Security
Configure firewall and disable unnecessary network services:

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

sudo systemctl disable avahi-daemon
sudo systemctl disable cups
sudo systemctl disable rpcbind
```

**Explanation:**
- Installs and configures Uncomplicated Firewall (UFW)
- Sets default policies to deny incoming and allow outgoing traffic
- Allows SSH connections
- Disables unnecessary network services

### 4. File System Security
Enhance file system security with appropriate permissions and mount options:

```bash
sudo chmod 700 /boot /etc/cron.monthly /etc/cron.weekly /etc/cron.daily /etc/cron.hourly
sudo chmod 600 /etc/crontab /etc/ssh/sshd_config
sudo chmod 644 /etc/passwd
sudo chmod 640 /etc/shadow
sudo chmod 644 /etc/group
sudo chmod 640 /etc/gshadow

echo "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" | sudo tee -a /etc/fstab
```

**Explanation:**
- Sets restrictive permissions on critical system directories and files
- Configures `/run/shm` with secure mount options

### 5. Secure SSH
Enhance SSH security configuration:

```bash
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

**Explanation:**
- Disables root login via SSH
- Disables password authentication (use key-based authentication)
- Disables X11 forwarding
- Restarts SSH service to apply changes

### 6. Install and Configure fail2ban
Implement intrusion prevention with fail2ban:

```bash
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**Explanation:**
- Installs fail2ban
- Creates a local configuration file
- Sets ban time to 1 hour and max retries to 3
- Enables and starts fail2ban service

### 7. Remove Unnecessary Packages
Remove potentially vulnerable or unnecessary packages:

```bash
sudo apt remove telnet rsh-client rsh-redone-client -y
```

**Explanation:**
- Removes telnet and rsh clients, which are insecure protocols

### 8. Enable and Configure auditd
Set up system auditing:

```bash
sudo apt install auditd -y
sudo systemctl enable auditd
sudo systemctl start auditd
```

**Explanation:**
- Installs auditd (Linux Audit daemon)
- Enables and starts the audit service

### 9. Disable USB Storage
Prevent unauthorized data exfiltration via USB devices:

```bash
echo "install usb-storage /bin/true" | sudo tee -a /etc/modprobe.d/disable-usb-storage.conf
```

**Explanation:**
- Disables USB storage module loading

### 10. Secure Shared Memory
Protect shared memory from potential exploits:

```bash
echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
```

**Explanation:**
- Mounts `/dev/shm` with secure options

## Post-Hardening Steps
After applying all hardening measures:

1. Thoroughly review all changes to ensure they align with your security requirements.
2. Conduct comprehensive testing to verify that all necessary system functions are working correctly.
3. Reboot the system to apply all changes:
   ```bash
   sudo reboot

4. After reboot, verify that all services and applications are functioning as expected.

## Validation and Testing
To ensure the effectiveness of the hardening measures:

1. **Vulnerability Scanning:**
   - Use tools like OpenVAS or Nessus to scan for vulnerabilities.
   - Run `sudo lynis audit system` for a comprehensive security audit.

2. **Penetration Testing:**
   - Conduct external and internal penetration tests.
   - Use tools like Metasploit to simulate potential attacks.

3. **Compliance Checking:**
   - Utilize OpenSCAP to check compliance with security standards like DISA STIG or CIS Benchmarks.
   - Run `sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig-rhel7-disa --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml`

4. **Log Analysis:**
   - Regularly review system logs using tools like `journalctl` or log analysis software.
   - Set up log monitoring and alerting for suspicious activities.

5. **Network Security:**
   - Use `nmap` to scan for open ports and verify firewall configurations.
   - Employ Wireshark or tcpdump for detailed network traffic analysis.

## Troubleshooting
Common issues and their solutions:

1. **SSH Access Issues:**
   - Verify SSH configuration in `/etc/ssh/sshd_config`
   - Ensure the firewall allows SSH (port 22 by default)

2. **System Update Failures:**
   - Check internet connectivity
   - Verify repository sources in `/etc/apt/sources.list`

3. **Application Compatibility:**
   - Some applications may not work with stricter security settings. Review logs and adjust policies as needed.

4. **Performance Impact:**
   - Monitor system performance after hardening. Adjust resource-intensive security measures if necessary.

## Contributing
I welcome contributions to improve this hardening guide. To contribute:

1. Fork the repository and create your branch from `main`.
2. Ensure your code adheres to the project's coding standards.
3. Test your changes thoroughly in a non-production environment.
4. Submit a pull request with a clear description of your changes and their benefits.

All contributions will undergo a security review before merging.

## Reporting Security Vulnerabilities
If you discover a security vulnerability, please email [martineliseo@duck.com](mailto:martineliseo@duck.com).
I will address all security-related issues promptly.

Please refrain from disclosing security-related issues publicly until a fix has been announced.

## Disclaimer
These hardening commands are provided as-is and may not be suitable for all environments. Always test in a non-production environment first and consult with your organization's security policies before implementing. The authors and contributors of this project are not responsible for any damages or security breaches resulting from the use of these commands.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by security enthusiasts for the community
</p>
