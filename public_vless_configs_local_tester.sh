#This is my first somewhat decently sized project.
#It's mainly about overcoming RKN's whitelists with the help of publicly available VLESS VPN configs from www.github.com/igareck.
#I'll mainly try to focus on Termux compatability with the script since whitelists mainly affect me when I'm outside and Termux is my go-to option.

pkg install nmap -y
pkg install cronie -y
mkdir $HOME/VLESS
cd $HOME/VLESS

cat << 'EOF' > vless_checker.sh
#!/bin/bash

cd "$HOME/VLESS" || exit 1

if ! wget -q -O unchecked_vless.txt https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/WHITE-CIDR-RU-checked.txt; then 
    echo "Failed to download the configs file."
    exit 1
fi

> working_vless.txt
echo "$(date +'%Y-%m-%d %T')" >> working_vless.txt

while read -r link; do

    address_port=$(echo "$link" | grep -oP '(?<=@)[^/?#]+')

    ip="${address_port%:*}"
    port="${address_port#*:}"

    if [[ -z "$ip" || -z "$port" ]]; then
        echo "⚠️ Skipping invalid format: ${link:0:30}..."
        continue
    fi

    echo -n "Checking $ip:$port... "

    if timeout 1 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
        echo "$link" >> working_vless.txt
        echo "✅ WORKING"
    else
        echo "❌ FAILED"
    fi
done < unchecked_vless.txt

echo "Done! Working links saved to working_vless.txt"
EOF

chmod +x vless_checker.sh
./vless_checker.sh
(crontab -l 2>/dev/null; echo "26 3-17 * * 1-5 /bin/bash $HOME/VLESS/vless_checker.sh") | crontab -
