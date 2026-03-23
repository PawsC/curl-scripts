This is my first somewhat decently sized project.<br>
It's mainly about overcoming RKN's whitelists with the help of publicly available VLESS VPN configs from www.github.com/igareck.<br>
I'll try to focus on Termux compatability with the script since whitelists affect me when I'm outside and Termux is my go-to option.<br>
In order to get everything going - copy, paste and execute the commands below in the terminal:<br>
```
pkg install wget -y
pkg install nmap -y
pkg install cronie -y

mkdir $HOME/VLESS
cd $HOME/VLESS

wget https://github.com/PawsC/Public-VLESS-configs-local-tester/raw/refs/heads/main/vless_checker.sh
chmod +x vless_checker.sh
```
To start a script, run the command below:
```
./vless_checker.sh
```
[Optional] If you want to have the script to be automatically run, run the commands to add it to the cron service:
```
(crontab -l 2>/dev/null; echo "25 3-17 * * 1-5 /bin/bash $HOME/VLESS/vless_checker.sh >> $HOME/VLESS/cron.log 2>&1") | crontab -

crond
```
