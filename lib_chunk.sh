#!/bin/bash
# lib_chunk.sh — Shared Utilities for Chunk Transfer
# Source this file in other scripts using: source ./lib_chunk.sh

# === Config ===
CHUNK_FILE="map_1094_937.bin"
CHUNK_PATH="/home/pzserver/Zomboid/Saves/Multiplayer/pzserver"
CHUNK_FULL_PATH="$CHUNK_PATH/$CHUNK_FILE"

DELIVERY_DIR="/home/pzserver/staging/delivery"
BACKUP_DIR="/home/pzserver/staging/backup"
EMPTY_CHUNK="/home/pzserver/staging/empty/$CHUNK_FILE"

RCON_BIN="/home/pzserver/gorcon/rcon"
RCON_CONF="/home/pzserver/gorcon/rcon.yaml"

LOG_FILE="/home/pzserver/staging/chunk-swap.log"

# === Functions ===

log_msg() {
    local msg="$1"
    echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $msg" | tee -a "$LOG_FILE"
}

get_backup_index() {
    local last
    last=$(ls -1 "$BACKUP_DIR" 2>/dev/null | sort -n | tail -n 1)
    echo $((last + 1))
}


hash_file() {
    local file="$1"
    md5sum "$file" | awk '{print $1}'
}

verify_hash() {
    local file="$1"
    local expected="$2"

    local actual
    actual=$(hash_file "$file")

    [[ "$actual" == "$expected" ]]
}

send_server_msg() {
    local message="$1"
    "$RCON_BIN" -c "$RCON_CONF" "servermsg \"$message\""
}

# Validated functions
# Validated all manually as of 2025-06-10T15:32:00Z
# log_msg
# get_backup_index
# hash_file
# verify_hash
# send_server_msg