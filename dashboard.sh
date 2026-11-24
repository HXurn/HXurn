#!/data/data/com.termux/files/usr/bin/bash

C='\033[36m'
G='\033[32m'
D='\033[90m'
R='\033[0m'

device=$(getprop ro.product.model)
android=$(getprop ro.build.version.release)
kernel=$(uname -r)
uptime=$(uptime -p 2>/dev/null | sed 's/up //')
cores=$(nproc 2>/dev/null || echo "?")

# Shell version
if command -v zsh >/dev/null 2>&1; then
    shell_version=$(zsh --version | awk '{print $2}')
else
    shell_version="unknown"
fi

# Memory
mem=$(free -h 2>/dev/null | awk '/^Mem:/ {
    printf "%s used, %s available, %s total", $3, $7, $2
}')

[ -z "$mem" ] && mem="unavailable"

# Load average
load=$(awk '{print $1", "$2", "$3}' /proc/loadavg 2>/dev/null)
[ -z "$load" ] && load="unavailable"

# Process count
processes=$(ps -A 2>/dev/null | awk 'NR>1 {n++} END {print n+0}')

# Disk
read -r disk_used disk_free disk_total used_pct < <(
    df -h /data | awk 'NR==2 {
        gsub("%","",$5)
        print $3, $4, $2, $5
    }'
)

[ -z "$used_pct" ] && used_pct=0

# Temperature
temperature="unavailable"

for zone in /sys/class/thermal/thermal_zone*/temp; do
    if [ -r "$zone" ]; then
        value=$(cat "$zone" 2>/dev/null)

        if [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -gt 0 ]; then
            if [ "$value" -gt 1000 ]; then
                temperature=$(awk -v t="$value" 'BEGIN {printf "%.1f°C", t/1000}')
            else
                temperature="${value}°C"
            fi
            break
        fi
    fi
done

# Directory summary
folders=$(find . -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
files=$(find . -mindepth 1 -maxdepth 1 -type f 2>/dev/null | wc -l)

# Header
printf "${C}"
printf "  ╭────────────────────────────────────╮\n"
printf "  │              HXurn                │\n"
printf "  │       Termux Environment           │\n"
printf "  ╰────────────────────────────────────╯\n"
printf "${R}\n"

printf "${G}  Shell     : Zsh %s${R}\n" "$shell_version"
printf "${G}  Time      : %s${R}\n\n" "$(date +%H:%M:%S)"

printf "${C}  Project   : %s${R}\n" "${PWD##*/}"
printf "${C}  Directory : %s${R}\n\n" "$PWD"

printf "${D}System Info:${R}\n"
printf "  ${C}Distro${R}    : Android %s\n" "$android"
printf "  ${C}Host${R}      : %s\n" "$device"
printf "  ${C}Kernel${R}    : %s\n" "$kernel"

printf "\n"
printf "  ${C}Uptime${R}    : %s\n" "$uptime"
printf "  ${C}Load${R}      : %s\n" "$load"
printf "  ${C}Processes${R}  : %s\n" "$processes"

printf "\n"
printf "  ${C}CPU${R}       : (%s vCPU)\n" "$cores"
printf "  ${C}Memory${R}    : %s\n" "$mem"

printf "\n${D}Temperature:${R} %s\n" "$temperature"

printf "\n${D}Disk Usage:${R}\n"
printf "  /data       %s used out of %s\n" "$disk_used" "$disk_total"
printf "  Available   %s free\n" "$disk_free"

filled=$((used_pct * 30 / 100))
empty=$((30 - filled))

printf "  ${G}"
printf '%*s' "$filled" '' | tr ' ' '#'
printf "${D}"
printf '%*s' "$empty" '' | tr ' ' '-'
printf "${R} %s%%\n" "$used_pct"

printf "\033[90m──────────────────────────────────────────────────────────────\033[0m\n"
printf "\033[36m HXurn \033[90m│\033[32m TERMUX \033[90m│\033[36m ZSH \033[90m│\033[32m NORMAL\033[0m\n"
printf "\033[90m──────────────────────────────────────────────────────────────\033[0m\n"

printf "\n\033[36mDirectory Summary:\033[0m\n"
printf "  Folders : %s\n" "$folders"
printf "  Files   : %s\n" "$files"
