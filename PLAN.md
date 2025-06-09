## Item Transfer Process (Chunk-Based)

### Pre-Transfer Actions
- Send message to clear the donation area. Log the timestamp.
- Admins go to chunk, teleport players out of the target chunk.

### Script Steps (Run on Donation Server)

1. **Check Timestamp**  
   Warn if `map_xxx_xxx.bin` was not modified after the clear message timestamp.
   Log the warning and prompt whether to proceed.  
   _(Note: safest action is to teleport in and out of the chunk manually to ensure it's unloaded.)_

2. **Hash Chunk**  
   Generate MD5 hash of `map_xxx_xxx.bin` and store in variable.

3. **Copy Files**  
   Copy `map_xxx_xxx.bin` and save hash to:
   - `/home/pzserver/staging/delivery` on event server.
   - `/home/pzserver/staging/backup/#` on local server (`#` auto-increments per transfer).

4. **Validate Backup**  
   Confirm MD5 hash of the local backup matches original.

5. **Wipe Chunk**  
   Replace `map_xxx_xxx.bin` with empty version from `/home/pzserver/staging/empty`.

6. **Notify Delivery**  
   Send message indicating delivery is ready.

   ## Item Receive Process (Chunk-Based)

### Pre-Transfer Actions
- Validate incoming `map_xxx_xxx.bin` using provided MD5 hash. Log error and notify if invalid.
- Send message to clear the incoming donation area. Log the timestamp.
- Admins teleport players out of the target chunk.

### Script Steps (Run on Event Server)

1. **Check Timestamp**  
   Warn if `map_xxx_xxx.bin` was not modified after the clear message timestamp.
   Log the warning and prompt whether to proceed.  
   _(Note: safest action is to teleport in and out of the chunk manually to ensure it's unloaded.)_