# Azure VM + Nginx + Rsync Setup Guide

Complete step-by-step guide for setting up an Azure VM with Nginx web server and deploying files using rsync.

## 📋 Prerequisites

- Azure account with active subscription
- SSH client (Git Bash, Terminal, or PuTTY)
- Basic knowledge of Linux commands

---

## 🚀 Step 1: Create Azure Virtual Machine

### 1.1 Create VM in Azure Portal

1. **Login to Azure Portal**: https://portal.azure.com
2. **Click "Create a resource"** → **"Virtual Machine"**
3. **Configure Basic Settings**:
   - **Subscription**: Select your subscription
   - **Resource Group**: Create new or use existing
   - **Virtual Machine Name**: `my-linux-ssh-vm` (or your choice)
   - **Region**: Choose closest region
   - **Image**: Ubuntu Server 20.04 LTS or 22.04 LTS
   - **Size**: Standard B1s (1 vCPU, 1 GB RAM) - sufficient for testing
   - **Authentication**: SSH public key
   - **Username**: `azureuser` (default)
   - **SSH Key**: Generate new or use existing

4. **Configure Networking**:
   - **Virtual Network**: Create new or use existing
   - **Subnet**: default
   - **Public IP**: Create new
   - **NIC Network Security Group**: Basic
   - **Public inbound ports**: Allow SSH (22)

5. **Review + Create** → **Create**

### 1.2 Get VM Connection Details

After deployment:
1. Go to your VM resource
2. Note down the **Public IP address**
3. Download the SSH private key (if generated new)

---

## 🔐 Step 2: Connect to VM via SSH

### 2.1 Connect using SSH

```bash
# Connect to your VM (replace with your actual IP)
ssh azureuser@[YOUR-VM-PUBLIC-IP]

# Example:
ssh azureuser@172.206.195.75
```

### 2.2 Update System

```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade -y
```

---

## 🌐 Step 3: Install and Configure Nginx

### 3.1 Install Nginx

```bash
# Install nginx
sudo apt install nginx -y

# Start nginx service
sudo systemctl start nginx

# Enable nginx to start on boot
sudo systemctl enable nginx

# Check nginx status
sudo systemctl status nginx
```

### 3.2 Test Nginx Locally

```bash
# Test if nginx is working
curl localhost

# Should return HTML content
```

### 3.3 Check Nginx Configuration

```bash
# Verify nginx is listening on port 80
sudo ss -tlnp | grep nginx

# Should show:
# LISTEN 0 511 0.0.0.0:80 0.0.0.0:* users:(("nginx",pid=xxx,fd=x))
```

---

## 🔒 Step 4: Configure Azure Network Security Group (NSG)

### 4.1 Add Inbound Rule for HTTP Traffic

1. **In Azure Portal** → Go to your VM → **Networking** tab
2. **Current rules show**: Only SSH (port 22) allowed
3. **Click "Add inbound port rule"**
4. **Configure HTTP Rule**:
   - **Source**: Any
   - **Source port ranges**: *
   - **Destination**: Any
   - **Destination port ranges**: **80**
   - **Protocol**: TCP
   - **Action**: Allow
   - **Priority**: 1000
   - **Name**: Allow-HTTP
5. **Click "Add"**

### 4.2 Verify Network Configuration

In Azure Portal → VM → Network settings:
- **Public IP address**: `172.206.195.75` (your actual IP)
- **Private IP address**: `10.0.0.4`
- **Admin security rules**: 2 (SSH + HTTP)

---

## 🌍 Step 5: Test External Access

### 5.1 Test from VM

```bash
# Test external access from within VM
curl http://[YOUR-PUBLIC-IP]

# Example:
curl http://172.206.195.75
```

### 5.2 Test from Browser

Open browser and navigate to:
```
http://[YOUR-PUBLIC-IP]
```

You should see the default Nginx welcome page.

---

## 📁 Step 6: Prepare Web Content Directory

### 6.1 Check Default Web Directory

```bash
# Nginx default web directory
ls -la /var/www/html/

# Should contain index.nginx-debian.html
```

### 6.2 Set Proper Permissions

```bash
# Make sure nginx can read/write
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

---

## 🔄 Step 7: Install and Use Rsync

### 7.1 Install Rsync on VM

```bash
# Install rsync (if not already installed)
sudo apt install rsync -y

# Verify installation
rsync --version
```

### 7.2 Set Up SSH Key Authentication

**Fix SSH key permissions in WSL:**

```bash
# Copy SSH keys from Windows to WSL
cp /mnt/c/Users/[username]/.ssh/azure_key2* ~/.ssh/

# Set correct permissions
chmod 600 ~/.ssh/azure_key2      # Private key
chmod 644 ~/.ssh/azure_key2.pub  # Public key
chmod 700 ~/.ssh                 # SSH directory

# Create SSH config for easier access
nano ~/.ssh/config
```

Add to SSH config:
```
Host 172.206.195.75
    User azureuser
    IdentityFile ~/.ssh/azure_key2
    IdentitiesOnly yes
```

**Test SSH connection:**
```bash
# Test passwordless SSH
ssh azureuser@172.206.195.75 'echo "Success"'
```

### 7.3 Create Automated Deployment Script

Create `simple-deploy.sh`:

```bash
#!/bin/bash

echo "🚀 Deploying website..."

# Clean any Windows metadata files
find ./website/ -name "*:Zone.Identifier" -delete

# Upload to user home directory (avoids permission issues)
echo "📤 Uploading files..."
rsync -avz --delete ./website/ azureuser@172.206.195.75:~/website-temp/

# Move to web directory and fix permissions
echo "🔧 Installing files..."
ssh azureuser@172.206.195.75 "
    sudo rm -rf /var/www/html/*
    sudo cp -r ~/website-temp/* /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod -R 755 /var/www/html/
    rm -rf ~/website-temp
    sudo systemctl reload nginx
"

echo "✅ Deployment complete!"
echo "🌐 Visit: http://172.206.195.75"
```

### 7.4 Deploy Your Website

```bash
# Make script executable
chmod +x simple-deploy.sh

# Deploy your website
./simple-deploy.sh
```

### 7.5 Project Structure

```
~/my-website-project/
├── simple-deploy.sh    # Deployment script
├── website/           # Your website files
│   ├── index.html
│   ├── style.css
│   └── images/
│       └── manchurian.jpg
└── README.md
```

---

## 🎯 Step 8: Deploy Your Website

### 8.1 Website Deployment Workflow

**Set up your project structure:**

```bash
# Create project directory in WSL
mkdir ~/my-website-project
cd ~/my-website-project

# Create website directory
mkdir website

# Add your website files
cp /mnt/c/Users/[username]/path/to/your/files/* website/
# Or create files directly:
nano website/index.html
```

### 8.2 One-Command Deployment

```bash
# Deploy your website with one command
./simple-deploy.sh
```

**Expected output:**
```
🚀 Deploying website...
📤 Uploading files...
sending incremental file list
./
index.html
images/manchurian.jpg

🔧 Installing files...
✅ Deployment complete!
🌐 Visit: http://172.206.195.75
```

### 8.3 Verify Deployment

```bash
# Test website access
curl http://172.206.195.75

# Or visit in browser:
http://172.206.195.75
```

### 8.4 Update Workflow

```bash
# 1. Edit your website files
nano website/index.html

# 2. Deploy changes
./simple-deploy.sh

# 3. Changes are live instantly!
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue: Can't access website externally
**Solution:**
1. Check NSG rules allow port 80
2. Verify nginx is running: `sudo systemctl status nginx`
3. Check firewall: `sudo ufw status` (should be inactive by default)

#### Issue: SSH key permission denied
**Solution:**
```bash
# Fix SSH key permissions in WSL
chmod 600 ~/.ssh/azure_key2
chmod 644 ~/.ssh/azure_key2.pub
chmod 700 ~/.ssh
```

#### Issue: Rsync permission denied
**Solution:**
```bash
# Use the two-step deployment approach:
# 1. Upload to user directory first
rsync -avz ./website/ azureuser@[VM-IP]:~/temp/

# 2. Move to web directory with sudo
ssh azureuser@[VM-IP] "sudo cp -r ~/temp/* /var/www/html/ && rm -rf ~/temp"
```

#### Issue: Zone.Identifier files causing errors
**Solution:**
```bash
# Clean Windows metadata files before deployment
find ./website/ -name "*:Zone.Identifier" -delete
```

#### Issue: Files not showing latest changes
**Solution:**
```bash
# Clear browser cache or use incognito mode
# Or restart nginx
ssh azureuser@[VM-IP] "sudo systemctl restart nginx"
```

---

## 📝 Step 9: Useful Commands Reference

### VM Management

```bash
# Check VM IP
curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text"

# Check internal IP
hostname -I
```

### Nginx Management

```bash
# Check nginx status
sudo systemctl status nginx

# Start/stop/restart nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Test nginx configuration
sudo nginx -t

# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### File Management

```bash
# List web directory contents
ls -la /var/www/html/

# View file contents
cat /var/www/html/index.html

# Check disk space
df -h

# Check directory sizes
du -sh /var/www/html/*
```

---

## 🎉 Success Checklist

- ✅ Azure VM created and accessible via SSH
- ✅ Ubuntu updated and nginx installed
- ✅ Nginx running and accessible locally (`curl localhost`)
- ✅ Azure NSG configured to allow HTTP traffic (port 80)
- ✅ SSH key authentication configured (passwordless access)
- ✅ Rsync installed and working
- ✅ Automated deployment script created (`simple-deploy.sh`)
- ✅ Website successfully deployed and accessible at public IP
- ✅ One-command deployment workflow established

## 📊 Final Result

**🌐 Live Website:** `http://172.206.195.75` (replace with your actual IP)

**🚀 Quick Deploy:** 
```bash
# Edit files in ./website/
nano website/index.html

# Deploy with one command
./simple-deploy.sh
```

**📁 Project Structure:**
```
~/my-website-project/
├── simple-deploy.sh    # One-click deployment
├── website/           # Your website files
│   ├── index.html
│   ├── style.css
│   └── images/
└── README.md         # This guide
```

---

## 🚀 Next Steps

1. **Domain Setup**: Point a domain name to your VM's public IP
2. **SSL Certificate**: Set up HTTPS with Let's Encrypt
3. **Automated Deployment**: Create scripts for automated rsync deployment
4. **Monitoring**: Set up logging and monitoring for your website
5. **Backup**: Implement regular backups of your web content

---

## 📚 Additional Resources

- [Azure VM Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Rsync Manual](https://download.samba.org/pub/rsync/rsync.html)
- [Azure Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

---

**🎯 Final Result**: A fully functional web server running on Azure VM, accessible from anywhere in the world, with the ability to easily deploy updates using rsync!