#!/bin/bash

# Config
TOPOLOGY_FILE="topology.clab.yaml"
LOG_FILE="lab-manager.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function start_lab() {
    echo -e "${GREEN}[$TIMESTAMP] Starting lab...${NC}" | tee -a "$LOG_FILE"
    if containerlab deploy -t "$TOPOLOGY_FILE" 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}[$TIMESTAMP] Lab started successfully!${NC}" | tee -a "$LOG_FILE"
        show_management_ips
    else
        echo -e "${RED}[$TIMESTAMP] Lab startup failed! Check $LOG_FILE${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
}

function stop_lab() {
    echo -e "${GREEN}[$TIMESTAMP] Stopping lab...${NC}" | tee -a "$LOG_FILE"
    if containerlab destroy -t "$TOPOLOGY_FILE" --cleanup 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}[$TIMESTAMP] Lab stopped successfully!${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}[$TIMESTAMP] Lab shutdown failed! Check $LOG_FILE${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
}

function show_management_ips() {
    echo -e "\n${GREEN}Management IP Addresses:${NC}"
    containerlab inspect -t "$TOPOLOGY_FILE" | grep -E 'Name|IPv4' | awk '/Name/ {printf "\n%s: ", $2} /IPv4/ {print $2}'
    echo ""
}

function show_menu() {
    echo -e "\n${GREEN}Containerlab Manager${NC}"
    echo "1. Start Lab"
    echo "2. Stop Lab"
    echo "3. Show Management IPs"
    echo "4. View Logs"
    echo "5. Exit"
}

# Main
while true; do
    show_menu
    read -p "Select option (1-5): " choice
    
    case $choice in
        1) start_lab ;;
        2) stop_lab ;;
        3) show_management_ips ;;
        4) less "$LOG_FILE" ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid choice!${NC}" ;;
    esac
done
