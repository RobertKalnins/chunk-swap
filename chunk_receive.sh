#!/bin/bash
# chunk_receive.sh — Run on receiving server (bontest2)
# Purpose: Validate, back up, and apply delivered chunk

set -euo pipefail

source "$(dirname "$0")/lib_chunk.sh"

# Step 1: Validate incoming chunk hash
DELIVERED_CHUNK="$DELIVERY_DIR/$CHUNK_FILE"
DELIVERED_HASH=$(<"$DELIVERY_DIR/hash.md5")

if verify_hash "$DELIVERED_CHUNK" "$DELIVERED_HASH"; then
    log_msg "Incoming delivery hash validated: $DELIVERED_HASH"
else
    log_msg "ERROR: Incoming chunk hash does not match!"
    send_server_msg "Delivery failed validation. Chunk hash mismatch."
    exit 1
fi

# Step 2: Send warning message + log timestamp
CLEAR_TIME=$(date -u +%s)
send_server_msg "Event server is preparing the donation. Please clear the area."
log_msg "Sent clear message at $(date -u --date=@$CLEAR_TIME)"

# Step 2.5: Wait for manual confirmation that the area is clear
read -rp "Press Enter once the donation area has been visually confirmed clear..."

# Step 3: Check timestamp of current active chunk
CHUNK_MODIFIED=$(stat -c %Y "$CHUNK_FULL_PATH")
if (( CHUNK_MODIFIED <= CLEAR_TIME )); then
    log_msg "WARNING: $CHUNK_FILE was NOT modified after clear message."
    read -rp "Chunk may still be loaded. Proceed anyway? (y/n) " choice
    [[ "$choice" != "y" ]] && log_msg "Aborted by user." && exit 1
fi

# Step 4: Backup current active chunk
BACKUP_INDEX=$(get_backup_index)
BACKUP_PATH="$BACKUP_DIR/$BACKUP_INDEX"
mkdir -p "$BACKUP_PATH"
cp "$CHUNK_FULL_PATH" "$BACKUP_PATH/"
CURRENT_HASH=$(hash_file "$CHUNK_FULL_PATH")
echo "$CURRENT_HASH" > "$BACKUP_PATH/hash.md5"
log_msg "Backed up current chunk to $BACKUP_PATH (hash: $CURRENT_HASH)"

# Step 5: Replace chunk with delivery
cp "$DELIVERED_CHUNK" "$CHUNK_FULL_PATH"
log_msg "Replaced active chunk with delivery copy."

# Step 6: Verify delivery hash after placement
if verify_hash "$CHUNK_FULL_PATH" "$DELIVERED_HASH"; then
    log_msg "Replacement hash confirmed: $DELIVERED_HASH"
else
    log_msg "WARNING: Final chunk hash does not match delivery hash!"
    read -rp "Continue anyway? (y/n) " choice
    [[ "$choice" != "y" ]] && log_msg "Aborted by user after mismatch." && exit 1
fi

# Step 7: Completion message
send_server_msg "Donation successfully delivered. All clear."
log_msg "Chunk receive complete."