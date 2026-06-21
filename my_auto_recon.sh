#!/bin/bash

# target
TARGET=127.0.0.1
PORT=80

# command
nmap_tcp="nmap -Pn -sVC -p-"
nmap_udp="nmap -Pn -sU -p-"
feroxbuster="feroxbuster"
nikto="nikto -h"

# wordlist
ferox_wordlist1="/gobuster/common.txt"
ferox_wordlist2="/gobuster/directory-list-2.3-medium.txt"


# color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# flag
run_nmap=false
run_ferox=false
run_nikto=false
run_all=false

usage() {
    cat << EOF
Usage: $(basename "$0") -t <target_ip> [options]

OSCP auto-recon script

Required:
  -t, --RHOST <ip>      Target IP address

Options:
  -p, --RPORT <port>    Target Web port
  -n,  --nmap            Run nmap
  -f,  --ferox           Run feroxbuster
  -N,  --nikto           Run nikto
  -h,  --help            Show this help

Examples:
  $(basename "$0") -t 192.168.45.200
  $(basename "$0") -t 192.168.45.200 -n -f
  $(basename "$0") -t 192.168.45.200 -p 8080
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -t|--RHOST)
        TARGET="$2"
        shift 2
        ;;
    -p|--RPORT)
        PORT="$2"
        shift 2
        ;;
    -n|--nmap)
        run_nmap=true
        shift 1
        ;;
    -f|--ferox)
        run_ferox=true
        shift 1
        ;;
    -N|--nikto)
        run_nikto=true
        shift 1
        ;;
    *)
        echo -e "${RED}[-] Unknown argument: $1${NC}" >&2
        usage
        ;;
    esac
done

# target options check
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[✘] Target is required${NC}" >&2
    usage
fi

if [[ "$run_nmap" == false && "$run_ferox" == false && "$run_nikto" == false ]]; then
    run_all=true
fi


nmap_tcp(){
    echo "[*]starting [tcp] nmap..."
    echo "$nmap_tcp $TARGET"
    $nmap_tcp $TARGET > nmap_tcp.txt
    echo "[*]finish [tcp] nmap..."
    echo "[*]===tcp scan result==="
    cat $(pwd)/nmap_tcp.txt
}

nmap_udp(){
    echo "[*]starting [udp] nmap..."
    $nmap_udp $TARGET > nmap_udp.txt
    echo "[*]finish [udp] nmap..."
    echo "[*]===udp scan result==="
    cat $(pwd)/nmap_udp.txt
}

ferox_1() {
    echo -e "${BLUE}[*] starting feroxbuster with ${ferox_wordlist1}...${NC}"
    ${feroxbuster} -u "http://${TARGET}:${PORT}" -w "${ferox_wordlist1}" -o ferox1_result.txt
    echo -e "${GREEN}[+] finish feroxbuster wordlist1${NC}"
    echo "[*] === feroxbuster wordlist1 result ==="
    cat $(pwd)/ferox1_result.txt
}

ferox_2() {
    echo -e "${BLUE}[*] starting feroxbuster with ${ferox_wordlist2}...${NC}"
    ${feroxbuster} -u "http://${TARGET}:${PORT}" -w "${ferox_wordlist2}" -o ferox2_result.txt
    echo -e "${GREEN}[+] finish feroxbuster wordlist2${NC}"
    echo "[*] === feroxbuster wordlist2 result ==="
    cat $(pwd)/ferox2_result.txt
}


nikto_1() {
    echo "[*]starting nikto..."
    $nikto $TARGET > nikto.txt
    echo "[*]finish nikto..."
    echo "[*]===nikto result==="
    cat $(pwd)/nikto.txt
}


if [[ "$run_nmap" == true || "$run_all" == true ]]; then

    nmap_tcp & pid1=$!
    nmap_udp & pid2=$!
    wait $pid1 $pid2
    echo -e "${GREEN}[+] nmap scan done!${NC}"
fi

if [[ "$run_ferox" == true || "$run_all" == true ]]; then
    if [[ "$run_nikto" == true || "$run_all" == true ]]; then
        ferox_1 & pid3=$!
        ferox_2 & pid4=$!
        nikto_1 & pid5=$!
        wait $pid3 $pid4 $pid5

    else
        ferox_1 & pid3=$!
        ferox_2 & pid4=$!
        wait $pid3 $pid4
    fi
fi

echo "Finish all scan!"
