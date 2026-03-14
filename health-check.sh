#!/bin/bash
# enhanced_boot_health_flags.sh
# Raspberry Pi Boot & Hardware Health Check with risk flags and timestamped output

# --- Generate timestamp ---
timestamp=$(date +"%y-%m-%d_%H-%M")
outfile="healthcheck-$timestamp.txt"

# --- Redirect stdout & stderr to tee ---
exec > >(tee "$outfile") 2>&1

echo "=============================="
echo "BOOT & HARDWARE HEALTH CHECK - $(date)"
echo "Output file: $outfile"
echo "=============================="
echo ""

# --- Initialize risk counters ---
risk_count=0
risk_list=""

# --- 1. Failed systemd units ---
failed_units=$(systemctl --failed --no-pager --no-legend | awk '{print $1}')
if [[ -n "$failed_units" ]]; then
    risk_count=$((risk_count+1))
    risk_list+="⚠ Failed units: $failed_units\n"
fi

# --- 2. Network-related services ---
network_services=$(systemctl list-units --type=service --state=running | grep -iE "tailscale|caddy|docker|containerd|code-server|nvmf" || true)
if [[ -n "$network_services" ]]; then
    risk_count=$((risk_count+1))
    risk_list+="⚠ Network-related running services: $network_services\n"
fi

# --- 3. CPU/GPU temperature ---
high_temp_flag=""
if command -v vcgencmd >/dev/null 2>&1; then
    cpu_temp=$(vcgencmd measure_temp | grep -oE '[0-9]+\.[0-9]+')
    cpu_temp_int=${cpu_temp%.*}
    if (( cpu_temp_int > 80 )); then
        high_temp_flag="⚠ High CPU temp: ${cpu_temp}°C"
        risk_count=$((risk_count+1))
        risk_list+="$high_temp_flag\n"
    fi
fi

# --- 4. Under-voltage detection ---
under_voltage=$(dmesg | grep -i -E "under-voltage|voltage")
if [[ -n "$under_voltage" ]]; then
    risk_count=$((risk_count+1))
    risk_list+="⚠ Under-voltage detected in dmesg\n"
fi

# --- 5. Watchdog warnings ---
watchdog_active=$(systemctl is-active watchdog 2>/dev/null)
if [[ "$watchdog_active" == "active" ]]; then
    risk_count=$((risk_count+1))
    risk_list+="⚠ Watchdog is active; may trigger reboots if misconfigured\n"
fi

# --- 6. NVMe issues ---
nvme_errors=$(sudo dmesg | grep -i nvme)
if [[ -n "$nvme_errors" ]]; then
    risk_count=$((risk_count+1))
    risk_list+="⚠ NVMe errors detected\n"
fi

# --- 7. Print Risk Summary ---
echo "=== RISK SUMMARY ==="
if [[ $risk_count -eq 0 ]]; then
    echo "No immediate risks detected."
else
    echo -e "$risk_list"
fi
echo "------------------------------"

# --- Full Health Check --- (same as previous script)

# Failed units
echo ">>> Failed systemd units:"
systemctl --failed
echo "------------------------------"

# Enabled units at boot
echo ">>> Units enabled at boot:"
systemctl list-unit-files --state=enabled
echo "------------------------------"

# Masked services
echo ">>> Masked services:"
systemctl list-unit-files | grep masked
echo "------------------------------"

# Active services
echo ">>> Active services:"
systemctl list-units --type=service --state=running
echo "------------------------------"

# Timers
echo ">>> Timers:"
systemctl list-timers --all
echo "------------------------------"

# Cron jobs
echo ">>> Cron jobs per user:"
for u in $(cut -f1 -d: /etc/passwd); do
    echo "User: $u"
    crontab -l -u $u 2>/dev/null || echo "No cron jobs"
done
echo "------------------------------"

# rc.local
echo ">>> /etc/rc.local contents:"
[ -f /etc/rc.local ] && cat /etc/rc.local || echo "No /etc/rc.local"
echo "------------------------------"

# Network info
echo ">>> Network interfaces:"
ip addr show
echo ""
echo ">>> Default routes:"
ip route show
echo ""
echo ">>> Listening sockets:"
ss -tulpn
echo "------------------------------"

# CPU/GPU temp & throttling
echo ">>> CPU & GPU temperature:"
if command -v vcgencmd >/dev/null 2>&1; then
    echo "CPU temp: $(vcgencmd measure_temp)"
    echo "Throttled status: $(vcgencmd get_throttled)"
fi
echo "------------------------------"

# Voltage/under-voltage
echo ">>> Voltage / Under-voltage events:"
dmesg | grep -i -E "under-voltage|voltage"
echo "------------------------------"

# Watchdog
echo ">>> Watchdog status:"
systemctl status watchdog --no-pager
echo ""
echo ">>> Watchdog recent log:"
journalctl -u watchdog -n 20 --no-pager
echo "------------------------------"

# NVMe
echo ">>> NVMe devices:"
nvme list 2>/dev/null || echo "No NVMe devices detected"
echo ""
echo ">>> NVMe filesystems:"
for dev in $(lsblk -ndo NAME,TYPE | awk '$2=="part"{print $1}'); do
    sudo blkid /dev/$dev
    sudo fsck -n /dev/$dev 2>/dev/null
done
echo "------------------------------"

# CPU frequency & governor
echo ">>> CPU frequency & governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "------------------------------"

# Summary suggestion
echo ">>> Recommendations:"
echo "- Review flagged items in the risk summary above."
echo "- Check failed units and unnecessary services."
echo "- Ensure proper 5.1V 3A+ USB-C power supply."
echo "- Monitor CPU/GPU temperature; add heatsinks/fans if needed."
echo "- Watchdog misconfiguration can trigger reboots; disable temporarily for diagnostics."
echo "- Ensure NVMe devices are healthy and filesystems clean."

echo ""
echo "Boot & Hardware Health Check Complete."
echo "Full output saved to: $outfile"
