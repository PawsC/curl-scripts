#This is my first somewhat decently sized project.
#It's mainly about overcoming RKN's whitelists with the help of publicly available VLESS VPN configs from www.github.com/igareck.
#I'll mainly try to focus on Termux compatability with the script since whitelists mainly affect me when I'm outside and Termux is my go-to option.

pkg install nmap -y
mkdir $HOME/VLESS
cd $HOME/VLESS
wget -O unchecked_vless.txt https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/WHITE-CIDR-RU-checked.txt
cat << 'EOF' > vless_checker.sh
#!/bin/bash
while read -r link; do
    address_port=$(echo "$link" | grep -oP '(?<=@)[^/?#]+')

    ip="${address_port%:*}"
    port="${address_port#*:}"

    if [[ -z "$ip" || -z "$port" ]]; then
        echo "⚠️ Skipping invalid format: ${link:0:30}..."
        continue
    fi

    echo -n "Checking $ip:$port... "

    if timeout 3 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
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
cat working_vless.txt
