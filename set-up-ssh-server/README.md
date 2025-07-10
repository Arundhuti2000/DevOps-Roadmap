# Remote Linux Server Setup with SSH on Azure

## Overview

This project guides you through setting up a basic Linux server on Microsoft Azure, securing it with SSH key-based authentication using two distinct key pairs, configuring SSH aliases for convenient access, and optionally installing Fail2ban to enhance security against brute-force attacks.

**Azure Student Free Account Note:** This setup is designed to largely fall within the free tier limits of an Azure Student Free Account, incurring minimal to no cost for compute resources if a free-eligible VM size is chosen and the VM is deallocated when not in use. Storage costs will still apply but are typically very low.

## Requirements

- An active Azure for Students account
- A local machine with `ssh-keygen` and `ssh` client installed (most Linux/macOS systems, Windows 10/11 with OpenSSH, or Git Bash)

## Steps

### 1. Set Up the Server (Azure Virtual Machine)

#### Log in to the Azure Portal
- Go to https://portal.azure.com/ and sign in with your student account

#### Create a Virtual Machine
- In the Azure portal search bar, type "Virtual machines" and select it
- Click "+ Create" > "Azure virtual machine"

#### Configure Basics Tab
- **Subscription:** Your "Azure for Students" subscription
- **Resource group:** Click "Create new" and name it (e.g., `my-ssh-server-rg`)
- **Virtual machine name:** Choose a unique name (e.g., `my-linux-ssh-vm`)
- **Region:** Select a region close to you
- **Image:** Select "Ubuntu Server 22.04 LTS Gen2" (or latest LTS)
- **Size:** Crucially, select a free-eligible VM size like `Standard_B1s`. Azure often highlights these as "Eligible for Azure Free Account"

#### Administrator Account
- **Authentication type:** "SSH public key"
- **Username:** Your chosen username (e.g., `azureuser`)
- **SSH public key source:** "Generate new key pair"
- **Key pair name:** `azure_key1_pair`

#### Inbound Port Rules
- **Public inbound ports:** "Allow selected ports"
- **Select inbound ports:** Check "SSH (22)"

#### Review and Create
- Proceed through the "Disks," "Networking," "Management," etc., tabs, accepting defaults for this basic setup
- Click "Review + create"
- After review, click "Create"
- A "Generate new key pair" pop-up will appear. Click "Download private key and create resource". Save the `.pem` file (e.g., `azure_key1_pair.pem`) to your local machine in a secure location (e.g., `~/.ssh/` on Linux/macOS, or `C:\Users\<YourUser>\.ssh\` on Windows). **This is your first private key.**

#### Get VM Public IP
- Once deployment is complete, click "Go to resource"
- Note down the Public IP address displayed on the VM's Overview page

### 2. Generate SSH Key Pairs (Local Machine)

You have `azure_key1_pair.pem` from Azure. Now, create a second key locally.

1. Open your local terminal (Linux/macOS Terminal, Git Bash/WSL on Windows, or PowerShell/CMD)

2. Set correct permissions for `azure_key1_pair.pem`:

   **Linux/macOS:**
   ```bash
   chmod 400 ~/.ssh/azure_key1_pair.pem
   ```

   **Windows (PowerShell/CMD - if saved in .ssh folder):**
   ```powershell
   icacls C:\Users\<YourUser>\.ssh\azure_key1_pair.pem /inheritance:r
   icacls C:\Users\<YourUser>\.ssh\azure_key1_pair.pem /grant:r "$($env:USERNAME):(R)"
   ```
   *(Replace `<YourUser>` with your Windows username)*

3. Generate the second SSH key pair:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key2
   ```
   - Press Enter twice for an empty passphrase (or enter one for better security)
   - This creates `~/.ssh/azure_key2` (private) and `~/.ssh/azure_key2.pub` (public)

### 3. Add SSH Keys to the Server

Add the public part of `azure_key2` to your Azure VM.

1. SSH into your VM using the first key:
   ```bash
   ssh -i ~/.ssh/azure_key1_pair.pem azureuser@<YOUR_VM_PUBLIC_IP>
   ```
   - Replace `<YOUR_VM_PUBLIC_IP>` and `azureuser`
   - Type `yes` if prompted to confirm host authenticity

2. On the server (in the SSH session):
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   nano ~/.ssh/authorized_keys
   ```

3. On your local machine (in a new terminal window):
   ```bash
   cat ~/.ssh/azure_key2.pub
   ```
   - Copy the entire output (the long `ssh-rsa ...` string)

4. Back on the server (in the SSH session):
   - Paste the copied public key content on a new line in nano
   - Ensure there are no extra spaces or line breaks within the key itself
   - Save: `Ctrl+O`, then Enter
   - Exit: `Ctrl+X`

5. Set permissions for authorized_keys:
   ```bash
   chmod 600 ~/.ssh/authorized_keys
   ```

6. Exit the SSH session:
   ```bash
   exit
   ```

### 4. Configure and Test SSH Connections

Verify both keys work.

1. Test with `azure_key1_pair.pem`:
   ```bash
   ssh -i ~/.ssh/azure_key1_pair.pem azureuser@<YOUR_VM_PUBLIC_IP>
   ```
   *(Connect, then exit)*

2. Test with `azure_key2`:
   ```bash
   ssh -i ~/.ssh/azure_key2 azureuser@<YOUR_VM_PUBLIC_IP>
   ```
   *(Connect, then exit)*

### 5. Configure an SSH Alias (~/.ssh/config)

Simplify connections on your local machine.

1. On your local machine, open/create `~/.ssh/config`:
   ```bash
   nano ~/.ssh/config
   ```

2. Add the following entries:
   ```
   # Alias for connecting with the first key
   Host myazurevm1
       HostName <YOUR_VM_PUBLIC_IP>
       User azureuser
       IdentityFile ~/.ssh/azure_key1_pair.pem

   # Alias for connecting with the second key
   Host myazurevm2
       HostName <YOUR_VM_PUBLIC_IP>
       User azureuser
       IdentityFile ~/.ssh/azure_key2
   ```
   - Replace placeholders with your VM's details

3. Save and exit: `Ctrl+O`, Enter, `Ctrl+X`

4. Set permissions for config file:
   ```bash
   chmod 600 ~/.ssh/config
   ```

### 6. Test SSH Connection with Alias

```bash
ssh myazurevm1
ssh myazurevm2
```

Both commands should now connect you to your VM.

### 7. Install Fail2ban for Enhanced Security (Optional)

Protect your server from brute-force attacks.

1. SSH into your Azure VM (e.g., `ssh myazurevm1`)

2. Update package lists:
   ```bash
   sudo apt update
   ```

3. Install Fail2ban:
   ```bash
   sudo apt install fail2ban -y
   ```

4. Configure Fail2ban for SSH:

   Copy default config:
   ```bash
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   ```

   Edit local config:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```

   In `jail.local`, ensure the `[sshd]` section is enabled and review `bantime`, `findtime`, `maxretry` (defaults are usually fine):
   ```ini
   # [DEFAULT] section (usually at the top)
   bantime = 10m
   findtime = 10m
   maxretry = 5

   # ... (scroll down to [sshd] section) ...

   [sshd]
   enabled = true
   port = ssh
   filter = sshd
   logpath = %(sshd_log)s
   ```

   Save and exit: `Ctrl+O`, Enter, `Ctrl+X`

5. Restart and Enable Fail2ban:
   ```bash
   sudo systemctl restart fail2ban
   sudo systemctl enable fail2ban
   ```

6. Verify status (optional):
   ```bash
   sudo systemctl status fail2ban
   sudo fail2ban-client status sshd
   ```

## ⚠️ Important Security Note

**DO NOT** push your private SSH keys (`.pem` or files without `.pub` extension) to any public repository. This README.md file contains all the necessary steps and information for your submission.