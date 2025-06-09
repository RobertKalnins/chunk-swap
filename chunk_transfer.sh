#!/bin/bash
# chunk_transfer.sh — Run on donation server (bontest1)
# Purpose: Backup, transfer, and wipe the donation chunk

set -euo pipefail

source "$(dirname "$0")/lib_chunk.sh"

# Step 1: Send warning message + log timestamp
CLEAR_TIME=$(date -u +%s)
send_server_msg "Please clear the donation area. Admins will begin the transfer shortly."
log_msg "Sent clear message at $(date -u --date=@$CLEAR_TIME)"

# Step 1.5: Wait for manual confirmation that the area is clear
read -rp "Press Enter once the donation area has been visually confirmed clear..."

# Step 2: Check if chunk was modified after CLEAR_TIME
CHUNK_MODIFIED=$(stat -c %Y "$CHUNK_FULL_PATH")
if (( CHUNK_MODIFIED <= CLEAR_TIME )); then
    log_msg "WARNING: $CHUNK_FILE was NOT modified after clear message."
    read -rp "Chunk may not be safely unloaded. Proceed anyway? (y/n) " choice
    [[ "$choice" != "y" ]] && log_msg "Aborted by user." && exit 1
fi

# Step 3: Generate MD5 hash
CHUNK_HASH=$(hash_file "$CHUNK_FULL_PATH")
log_msg "Generated hash: $CHUNK_HASH"

# Step 4: Create and validate local backup
BACKUP_INDEX=$(get_backup_index)
BACKUP_PATH="$BACKUP_DIR/$BACKUP_INDEX"
mkdir -p "$BACKUP_PATH"
cp "$CHUNK_FULL_PATH" "$BACKUP_PATH/"
echo "$CHUNK_HASH" > "$BACKUP_PATH/hash.md5"
log_msg "Backed up chunk to $BACKUP_PATH"

if verify_hash "$BACKUP_PATH/$CHUNK_FILE" "$CHUNK_HASH"; then
    log_msg "Backup hash verified."
else
    log_msg "ERROR: Backup hash mismatch!"
    log_msg "Chunk transfer aborted."
    exit 1
fi

# Step 5: Copy from backup to delivery and remote
scp "$BACKUP_PATH/$CHUNK_FILE" "pzserver@bontest2.beanster.fun:$DELIVERY_DIR/"
scp "$BACKUP_PATH/hash.md5" "pzserver@bontest2.beanster.fun:$DELIVERY_DIR/"
log_msg "Transferred chunk and hash to event server"

# Step 6: Replace with empty chunk
cp "$EMPTY_CHUNK" "$CHUNK_FULL_PATH"
log_msg "Chunk wiped and replaced with empty version."

# Step 7: Final notification
send_server_msg "Delivery ready. The donation has been cleared and transferred."
log_msg "Transfer complete. Chunk safely backed up, transferred, and wiped."