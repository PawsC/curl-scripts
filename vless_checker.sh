#!/bin/bash

WORKDIR="$HOME/VLESS"
URLS="https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/WHITE-CIDR-RU-checked.txt;https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/Vless-Reality-White-Lists-Rus-Mobile.txt"
FILE="$WORKDIR/unchecked_vless.txt"
OUTFILE="$WORKDIR/working_vless.txt"

cd "$HOME/VLESS" || exit 1

download_file() {
    echo "Downloading config lists..."

    > "$FILE"

    IFS=';' read -ra SOURCES <<< "$URLS"

    for url in "${SOURCES[@]}"; do
        echo "Fetching: $url"

        if ! wget -q -O - "$url" >> "$FILE"; then
            echo "⚠️ Failed to download: $url"
        fi
    done
    
    # Deduplicate
    sort -u "$FILE" -o "$FILE"

    if [[ ! -s "$FILE" ]]; then
        echo "❌ ERROR: No valid data downloaded."
        exit 1
    fi

    echo "Download complete. Combined sources saved to $FILE"
}

# First run / update logic
if [[ ! -f "$FILE" ]]; then
    echo "Config file not found. First run → downloading."
    download_file
else
    if [ -t 0 ]; then
        read -p "Download a fresh config list? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            download_file
        else
            echo "Using existing config list."
        fi
    fi
fi

# Thread input (only if interactive)
THREADS=1
if [ -t 0 ]; then
    while true; do
        read -p "How many threads: " THREADS
        if [[ "$THREADS" =~ ^[0-9]+$ ]] && (( THREADS > 0 )); then
            break
        else
            echo "Please enter a valid positive integer."
        fi
    done
fi

# Keep only valid lines (ip:port present after @)
grep -E '@[^ ]+:[0-9]+' "$FILE" > "$FILE.cleaned"
mv "$FILE.cleaned" "$FILE"

> "$OUTFILE"
echo "$(date +'%Y-%m-%d %T')" >> "$OUTFILE"

check_one() {
    link="$1"

    address_port=$(echo "$link" | grep -oP '(?<=@)[^/?#]+')

    ip="${address_port%:*}"
    port="${address_port#*:}"

    if [[ -z "$ip" || -z "$port" ]]; then
        echo "⚠️ Skipping invalid format"
        return
    fi

    if timeout 2 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
        echo "$link" >> "$OUTFILE"
        status="✅"
    else
        status="❌"
    fi

    echo "$status $ip:$port"
}

export -f check_one
export OUTFILE

# Parallel execution
TOTAL=$(wc -l < "$FILE")

nl -ba "$FILE" | while read -r num link; do
    (
        result=$(check_one "$link")
        printf "[%d/%d] %s\n" "$num" "$TOTAL" "$result"
    ) &
    
    # limit parallel jobs
    while (( $(jobs -r | wc -l) >= THREADS )); do
        sleep 0.1
    done
done

wait

echo "Done! Working links saved to $OUTFILE"
