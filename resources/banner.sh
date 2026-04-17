#!/usr/bin/env bash
# Standard colors mapped to 8-bit equivalents
ORANGE='\033[38;5;208m'
BLUE='\033[38;5;12m'
ERROR_RED='\033[38;5;9m'
GREEN='\033[38;5;2m'
ASH_GRAY='\033[38;5;250m'
NC='\033[0m'

# Constants
BUILD_TIMESTAMP=$(cat /usr/local/bin/build-timestamp.txt 2>/dev/null || echo "")

# Function to print separator line
print_separator() {
    printf "\n"
    printf "\n______________________________________________________________________________________________________________________________________________"
    printf "\n"
}

# Print ASCII art
print_ascii_art() {
    printf "${ORANGE}  /SSSSSS                                                            /SS      /SS  /SSSSSS  /SSSSSSS     ${NC}\n"
    printf "${ORANGE} /SS__  SS                                                          | SSS    /SSS /SS__  SS| SS__  SS    ${NC}\n"
    printf "${ORANGE}| SS  \__/  /SSSSSS   /SSSSSS   /SSSSSS  /SSSSSSS   /SSSSSS         | SSSS  /SSSS| SS  \__/| SS  \ SS    ${NC}\n"
    printf "${ORANGE}|  SSSSSS  /SS__  SS /SS__  SS /SS__  SS| SS__  SS |____  SS /SSSSSS| SS SS/SS SS| SS      | SSSSSSS/    ${NC}\n"
    printf "${ORANGE} \____  SS| SSSSSSSS| SS  \__/| SSSSSSSS| SS  \ SS  /SSSSSSS|______/| SS  SSS| SS| SS      | SS____/     ${NC}\n"
    printf "${ORANGE} /SS  \ SS| SS_____/| SS      | SS_____/| SS  | SS /SS__  SS        | SS\  S | SS| SS    SS| SS          ${NC}\n"
    printf "${ORANGE}|  SSSSSS/|  SSSSSSS| SS      |  SSSSSSS| SS  | SS|  SSSSSSS        | SS \/  | SS|  SSSSSS/| SS          ${NC}\n"
    printf "${ORANGE} \______/  \_______/|__/       \_______/|__/  |__/ \_______/        |__/     |__/ \______/ |__/          ${NC}\n"                                                                                             
    printf "\n"
    printf "\n"                                                                                                            
    printf "${ORANGE}  /SSSSSS                                                                                                ${NC}\n"
    printf "${ORANGE} /SS__  SS                                                                                               ${NC}\n"
    printf "${ORANGE}| SS  \__/  /SSSSSS   /SSSSSS  /SS    /SS /SSSSSS   /SSSSSS                                              ${NC}\n"
    printf "${ORANGE}|  SSSSSS  /SS__  SS /SS__  SS|  SS  /SS//SS__  SS /SS__  SS                                             ${NC}\n"
    printf "${ORANGE} \____  SS| SSSSSSSS| SS  \__/ \  SS/SS/| SSSSSSSS| SS  \__/                                             ${NC}\n"
    printf "${ORANGE} /SS  \ SS| SS_____/| SS        \  SSS/ | SS_____/| SS                                                   ${NC}\n"
    printf "${ORANGE}|  SSSSSS/|  SSSSSSS| SS         \  S/  |  SSSSSSS| SS                                                   ${NC}\n"
    printf "${ORANGE} \______/  \_______/|__/          \_/    \_______/|__/                                                   ${NC}\n"
                                                         
    printf "\n"
}

# Print Maintainer information
print_maintainer_info() {
    printf "\n"
    printf "${ASH_GRAY} ███╗   ███╗██████╗        ███╗   ███╗███████╗██╗  ██╗ █████╗ ██╗   ██╗███████╗██╗          █████╗ ███╗   ██╗██╗██╗  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ████╗ ████║██╔══██╗       ████╗ ████║██╔════╝██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔════╝██║         ██╔══██╗████╗  ██║██║██║ ██╔╝                 ${NC}\n"
    printf "${ASH_GRAY} ██╔████╔██║██║  ██║       ██╔████╔██║█████╗  █████╔╝ ███████║ ╚████╔╝ █████╗  ██║         ███████║██╔██╗ ██║██║█████╔╝                  ${NC}\n"
    printf "${ASH_GRAY} ██║╚██╔╝██║██║  ██║       ██║╚██╔╝██║██╔══╝  ██╔═██╗ ██╔══██║  ╚██╔╝  ██╔══╝  ██║         ██╔══██║██║╚██╗██║██║██╔═██╗                  ${NC}\n"
    printf "${ASH_GRAY} ██║ ╚═╝ ██║██████╔╝██╗    ██║ ╚═╝ ██║███████╗██║  ██╗██║  ██║   ██║   ███████╗███████╗    ██║  ██║██║ ╚████║██║██║  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ╚═╝     ╚═╝╚═════╝ ╚═╝    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝                 ${NC}\n"
}

# Print system information
print_system_info() {
    print_separator

    local disp_port="$PORT"
    local display_ip=$(ip route 2>/dev/null | awk '/default/ {print $3}' || echo "unknown")
    local port_display=":$disp_port"
    [[ "$disp_port" == '80' ]] && port_display=""

printf "${GREEN} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Starting Serena MCP Server! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n${NC}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ORANGE} PUID: %s${NC}\n" "$PUID"
printf "${ORANGE} PGID: %s${NC}\n" "$PGID"
printf "${ORANGE} MCP IP Address: %s\n${NC}" "$display_ip"
printf "${ORANGE} MCP Server PORT: ${GREEN}%s\n${NC}\n" "${disp_port:-80}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ERROR_RED} Note: You may need to change the IP address to your host machine IP\n${NC}"
[[ -n "$BUILD_TIMESTAMP" && -f "$BUILD_TIMESTAMP" ]] && BUILD_TIMESTAMP=$(cat "$BUILD_TIMESTAMP") && printf "${ORANGE}${BUILD_TIMESTAMP}${NC}\n"
    printf "${BLUE}This Container was started on:${NC} ${GREEN}$(date)${NC}\n"
}

# Main execution
main() {
    print_separator
    print_ascii_art
    print_maintainer_info
    print_system_info
}

main
