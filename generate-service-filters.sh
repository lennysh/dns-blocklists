#!/bin/bash

# Script to download AdGuard services.json and generate one filter file per service
# Each filter file contains the rules for that service in AdGuard filter format

set -e

# Configuration
SERVICES_JSON_URL="https://adguardteam.github.io/HostlistsRegistry/assets/services.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/service-filters"
TEMP_JSON="${SCRIPT_DIR}/services.json.tmp"
README_FILE="${OUTPUT_DIR}/README.md"
RAW_URL_BASE="https://raw.githubusercontent.com/lennysh/dns-blocklists/main/service-filters"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Downloading services.json...${NC}"

# Download services.json
if ! curl -s -f -o "${TEMP_JSON}" "${SERVICES_JSON_URL}"; then
    echo "Error: Failed to download services.json from ${SERVICES_JSON_URL}"
    exit 1
fi

echo -e "${GREEN}✓ Downloaded services.json${NC}"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Please install jq: sudo apt install jq  (or equivalent for your distro)"
    exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

echo -e "${BLUE}Generating filter files...${NC}"

# Get the number of services
SERVICE_COUNT=$(jq '.blocked_services | length' "${TEMP_JSON}")
echo "Found ${SERVICE_COUNT} services"

# Process each service
PROCESSED=0
SKIPPED=0

# Get array of service IDs
SERVICE_IDS=$(jq -r '.blocked_services[].id' "${TEMP_JSON}")

while IFS= read -r SERVICE_ID; do
    # Extract service information
    SERVICE_NAME=$(jq -r --arg id "${SERVICE_ID}" '.blocked_services[] | select(.id == $id) | .name' "${TEMP_JSON}")
    RULES_COUNT=$(jq -r --arg id "${SERVICE_ID}" '.blocked_services[] | select(.id == $id) | .rules | length' "${TEMP_JSON}")
    
    # Skip if no rules
    if [ "${RULES_COUNT}" -eq 0 ] || [ "${RULES_COUNT}" = "null" ]; then
        echo -e "${YELLOW}⚠ Skipping ${SERVICE_ID} (no rules)${NC}"
        ((SKIPPED++)) || true
        continue
    fi
    
    # Create filter file
    FILTER_FILE="${OUTPUT_DIR}/${SERVICE_ID}.txt"
    
    {
        # Write header
        echo "! Title: ${SERVICE_NAME} Block List"
        echo "! Description: AdGuard filter rules for blocking ${SERVICE_NAME}"
        echo "! Source: AdGuard Hostlists Registry"
        echo "! Service ID: ${SERVICE_ID}"
        echo "! Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "!"
        echo "! This filter blocks domains related to ${SERVICE_NAME}"
        echo "! Rules are sourced from: ${SERVICES_JSON_URL}"
        echo "!"
        echo ""
        
        # Write rules (one per line)
        jq -r --arg id "${SERVICE_ID}" '.blocked_services[] | select(.id == $id) | .rules[]' "${TEMP_JSON}" | while IFS= read -r rule; do
            if [ -n "${rule}" ] && [ "${rule}" != "null" ]; then
                echo "${rule}"
            fi
        done
    } > "${FILTER_FILE}"
    
    # Count rules in the file (excluding comments and empty lines)
    RULE_COUNT=$(grep -v '^!' "${FILTER_FILE}" | grep -v '^$' | wc -l)
    
    echo -e "${GREEN}✓ Created ${SERVICE_ID}.txt (${RULE_COUNT} rules)${NC}"
    ((PROCESSED++)) || true
done <<< "${SERVICE_IDS}"

# Clean up temp file
rm -f "${TEMP_JSON}"

# Generate README.md with all raw URLs
echo -e "${BLUE}Generating README.md with raw URLs...${NC}"

{
    echo "# Service Filter Blocklists"
    echo ""
    echo "Individual DNS blocklists for specific services. Copy the raw URL for any service you want to block."
    echo ""
    echo "> **Note:** This file is auto-generated. Do not edit manually."
    echo ">"
    echo "> **Last updated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    echo "## Quick Copy URLs"
    echo ""
    echo "Click on a service name to view the filter, or copy the raw URL to add to your DNS blocker."
    echo ""
    echo "| Service | Raw URL |"
    echo "|---------|---------|"
    
    # List all .txt files and generate table rows
    for filter_file in "${OUTPUT_DIR}"/*.txt; do
        if [ -f "${filter_file}" ]; then
            filename=$(basename "${filter_file}")
            service_id="${filename%.txt}"
            # Extract the service name from the filter file header
            service_name=$(grep "^! Title:" "${filter_file}" | sed 's/^! Title: //' | sed 's/ Block List$//')
            if [ -z "${service_name}" ]; then
                service_name="${service_id}"
            fi
            raw_url="${RAW_URL_BASE}/${filename}"
            echo "| [${service_name}](${raw_url}) | \`${raw_url}\` |"
        fi
    done
    
    echo ""
    echo "---"
    echo ""
    echo "## Usage"
    echo ""
    echo "### AdGuard Home"
    echo "1. Go to **Filters** → **DNS blocklists**"
    echo "2. Click **Add blocklist** → **Add a custom list**"
    echo "3. Paste any raw URL from above"
    echo ""
    echo "### Pi-hole"
    echo "1. Go to **Adlists**"
    echo "2. Paste the raw URL and click **Add**"
    echo "3. Run \`pihole -g\` to update"
    echo ""
    echo "### Technitium DNS Server"
    echo "1. Go to **Apps** → **Advanced Blocking**"
    echo "2. Add the raw URL as a blocklist"
    echo ""
    echo "---"
    echo ""
    echo "**Total blocklists available:** $(ls -1 "${OUTPUT_DIR}"/*.txt 2>/dev/null | wc -l)"
} > "${README_FILE}"

echo -e "${GREEN}✓ Generated README.md${NC}"

echo ""
echo -e "${GREEN}✓ Generation complete!${NC}"
echo "  Processed: ${PROCESSED} services"
echo "  Skipped: ${SKIPPED} services"
echo "  Output directory: ${OUTPUT_DIR}"
echo ""
echo "Filter files created:"
ls -1 "${OUTPUT_DIR}"/*.txt 2>/dev/null | wc -l | xargs echo "  Total files:"

