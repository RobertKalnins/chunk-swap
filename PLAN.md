## Item Transfer Process (Chunk-Based)

### Pre-Transfer Actions
- Send message to clear the donation area. Log the timestamp.
- Admins teleport players out of the target chunk.

### Script Steps (Run on Donation Server)

1. **Check Timestamp**  
   Abort if `map_xxx_xxx.bin` was not modified after the clear message timestamp. Log failure and notify.

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