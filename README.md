# VLESS Config Checker (Termux)

This is my first relatively large project.

The goal is to work around RKN whitelists using publicly available VLESS VPN configs from:
https://github.com/igareck/vpn-configs-for-russia

The script is primarily designed for **Termux**, since restrictions usually affect mobile usage.

---
## 🚀 Setup

Run the following commands:

```bash
pkg install wget -y
pkg install nmap -y
pkg install cronie -y

mkdir -p $HOME/VLESS
cd $HOME/VLESS

wget https://github.com/PawsC/Public-VLESS-configs-local-tester/raw/refs/heads/main/vless_checker.sh
chmod +x vless_checker.sh
```
---
## ▶️ Usage
Run the script:
```
./vless_checker.sh
```
## ⚙️ Settings
### Multiple sources
You can define multiple sources in the script by editing the URLS variable. Use semicolons (;) to separate them:
```
URLS="https://source1.txt;https://source2.txt;https://source3.txt"
```
### Threads
Each time you run the script, you will be asked to enter the number of threads.

* Must be a positive integer
* More threads = faster checking
* Too many threads may overload your network

## ⏱️ Automatic execution (cron)
To run the script automatically:
```
(crontab -l 2>/dev/null; echo "25 3-17 * * 1-5 /bin/bash $HOME/VLESS/vless_checker.sh >> $HOME/VLESS/cron.log 2>&1") | crontab -

crond
```
This runs the script:

* Monday–Friday
* Every hour from 03:25 to 17:25

