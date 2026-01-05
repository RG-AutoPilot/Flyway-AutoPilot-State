#!/usr/bin/env bash

# ===========================
# Script Name: Redgate_Offline_Permit_Decoding.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-12-16
# Description: Decode Offline Permit JWT and display product license information
# ===========================

set -euo pipefail

# -----------------------------
# CONFIGURATION
# -----------------------------
PRODUCTS_OF_INTEREST=("64")   # Product IDs to focus on (e.g 64 = Flyway)
EXPIRY_WARNING_DAYS=30        # Days threshold to warn

# -----------------------------
# INPUT
# -----------------------------
JWT="${1:-${PERMIT:-}}"

if [[ -z "$JWT" ]]; then
    if [[ ! -t 0 ]]; then
        JWT="$(cat)"
    else
        echo "Usage: $0 <JWT_TOKEN> or set PERMIT env variable or pipe JWT to stdin"
        exit 1
    fi
fi

JWT=$(echo "$JWT" | tr -d '\n\r ')

IFS='.' read -r HEADER PAYLOAD SIGNATURE <<< "$JWT"

# -----------------------------
# FUNCTIONS
# -----------------------------
decode_b64url() {
    local data="$1"
    data="${data//-+/}"
    data="${data//_/\/}"
    local mod=$(( ${#data} % 4 ))
    if (( mod != 0 )); then
        data="${data}$(printf '=%.0s' $(seq 1 $((4 - mod))))"
    fi
    echo "$data" | base64 -d 2>/dev/null
}

# -----------------------------
# DECODE PAYLOAD
# -----------------------------
decoded_payload=$(decode_b64url "$PAYLOAD")

echo "==== JWT PAYLOAD ===="
echo "$decoded_payload" | jq .

# -----------------------------
# OVERALL PERMIT EXPIRATION
# -----------------------------
exp=$(echo "$decoded_payload" | jq -r '.exp // empty')
if [[ -n "$exp" ]]; then
    now=$(date +%s)
    exp_date=$(date -d @"$exp" '+%Y-%m-%d %H:%M:%S')
    days_remaining=$(( (exp - now)/86400 ))
    echo ""
    echo "Permit expiration (exp): $exp ($exp_date) - $days_remaining day(s) remaining"
    if (( days_remaining <= 0 )); then
        echo "Status: ❌ EXPIRED"
    elif (( days_remaining <= EXPIRY_WARNING_DAYS )); then
        echo "Status: ⚠️ Approaching expiration"
    else
        echo "Status: ✅ VALID"
    fi
else
    echo ""
    echo "Warning: no exp claim found"
fi

# -----------------------------
# PRODUCTS OF INTEREST
# -----------------------------
echo ""
echo "=== Products of interest ==="
for prod in "${PRODUCTS_OF_INTEREST[@]}"; do
    product_info=$(echo "$decoded_payload" | jq -r --arg id "$prod" '.products[$id] // empty')
    if [[ -z "$product_info" ]]; then
        echo "Product $prod: ❌ Not found"
        continue
    fi
    license_count=$(echo "$product_info" | jq '.licenses | length')
    echo "Product $prod: $license_count license(s)"
    
    # Check each license for ignoreVersionUntil or expiry
    echo "$product_info" | jq -c '.licenses[]' | while read -r lic; do
        lic_id=$(echo "$lic" | jq -r '.licenseId')
        edition=$(echo "$lic" | jq -r '.editionName')
        major=$(echo "$lic" | jq -r '.majorVersion')
        minor=$(echo "$lic" | jq -r '.minorVersion')
        unit=$(echo "$lic" | jq -r '.entitlement.unit')
        ignore_until=$(echo "$lic" | jq -r '.ignoreVersionUntil // empty')
        expiry=$(echo "$lic" | jq -r '.expiry // empty')

        now=$(date +%s)
        status="✅ OK"

        if [[ -n "$ignore_until" ]]; then
            days_left=$(( (ignore_until - now)/86400 ))
            if (( days_left <= 0 )); then
                status="❌ EXPIRED"
            elif (( days_left <= EXPIRY_WARNING_DAYS )); then
                status="⚠️ Approaching expiration"
            fi
        elif [[ -n "$expiry" ]]; then
            exp_ts=$(date -d "$expiry" '+%s')
            days_left=$(( (exp_ts - now)/86400 ))
            if (( days_left <= 0 )); then
                status="❌ EXPIRED"
            elif (( days_left <= EXPIRY_WARNING_DAYS )); then
                status="⚠️ Approaching expiration"
            fi
        fi

        echo "  License $lic_id: $edition v$major.$minor ($unit) - $status"
    done
done
