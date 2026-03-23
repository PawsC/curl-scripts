#This is my first somewhat decently sized project.
#It's mainly about overcoming RKN's whitelists with the help of publicly available VLESS VPN configs from www.github.com/igareck.
#I'll mainly try to focus on Termux compatability with the script since whitelists mainly affect me when I'm outside and Termux is my go-to option.

#!/bin/bash
WORKDIR="$HOME/VLESS"
URL="https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/WHITE-CIDR-RU-checked.txt"
FILE="$WORKDIR/unchecked_vless.txt"
OUTFILE="$WORKDIR/working_vless.txt"

cd "$HOME/VLESS" || exit 1

download_file() {
    echo "Downloading config list..."
    if ! wget -q -O "$FILE" "$URL"; then
        echo "Failed to download the configs file."
        exit 1
    fi
    echo "Download complete."
}

if [[ ! -f "$FILE" ]]; then
    echo "Config file not found. First run → downloading."
    download_file
else
    # Ask only if running in terminal (not cron)
    if [ -t 0 ]; then
        read -p "Download a fresh config list? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            download_file
        else
            echo "Using existing config list."
        fi
    fi
fi

> "$OUTFILE"
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

    if timeout 2 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
        echo "$link" >> working_vless.txt
        echo "✅ WORKING"
    else
        echo "❌ FAILED"
    fi
done < "$FILE"

echo "Done! Working links saved to "$OUTFILE""
