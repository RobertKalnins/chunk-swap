## Item Transfer Process (Chunk-Based)

**Chunk Path:**  
`/home/pzserver/Zomboid/Saves/Multiplayer/pzserver/map_1094_937.bin`  
(Applies to both donation and receiving servers)

### Pre-Transfer Actions
- Send message to clear the donation area. Log the timestamp.
- Admins go to chunk, teleport players out of the target chunk.

### Script Steps (Run on Donation Server)

1. **Check Timestamp**  
   Warn if `map_1094_937.bin` (at path above) was not modified after the clear message timestamp.  
   Log the warning and prompt whether to proceed.  
   _Note: safest action is to teleport in and out of the chunk manually to ensure it's unloaded._

2. **Hash Chunk**  
   Generate MD5 (or SHA-256) hash of the target chunk and store in variable.

3. **Copy Files**  
   Copy chunk and hash to:
   - Event server: `/home/pzserver/staging/delivery`
   - Local backup: `/home/pzserver/staging/backup/#` (auto-incremented per transfer)

4. **Validate Backup**  
   Confirm hash of the local backup matches original.

5. **Wipe Chunk**  
   Replace original chunk with `/home/pzserver/staging/empty/map_1094_937.bin`.

6. **Notify Delivery**  
   Send message indicating delivery is ready.

---

## Item Receive Process (Chunk-Based)

**Chunk Path:**  
`/home/pzserver/Zomboid/Saves/Multiplayer/pzserver/map_1094_937.bin`

### Pre-Transfer Actions
- Validate incoming chunk using provided hash.  
  Abort, log error, and notify if invalid.
- Send message to clear the incoming donation area. Log the timestamp.
- Admins teleport players out of the target chunk.

### Script Steps (Run on Event Server)

1. **Check Timestamp**  
   Warn if active chunk at the target path was not modified after the clear message timestamp.  
   Log the warning and prompt whether to proceed.  
   _Note: safest action is to teleport in and out of the chunk manually to ensure it's unloaded._

   - Generate hash of current active chunk ("backup hash").
   - Copy it to `/home/pzserver/staging/backup/#` (auto-incremented), saving hash.

2. **Replace Chunk**  
   - Copy chunk from `/home/pzserver/staging/delivery` to the active location.
   - Validate the hash after placement.
   - Warn and prompt if hash does not match expected delivery hash.

3. **Completion**  
   - Send "All Clear" message to confirm delivery and reactivation.

## Rollback strategy
Admins can manually restore the pre-delivery chunk from staging/backup/# if needed