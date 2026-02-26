# CDECAD-Sync for QBCore

A comprehensive FiveM resource that automatically syncs QBCore character data to your CDECAD system.

## Features

- **Automatic Character Sync**: Characters are automatically synced to CDECAD when created/loaded
- **Discord Account Linking**: Links FiveM characters to users' CAD accounts via Discord ID
- **Discord Role Integration**: Filter syncing based on Discord roles (exclude LEO/EMS characters)
- **Vehicle Registration**: Automatically register vehicles when purchased
- **911 Call System**: Full 911 call integration with coordinates and postal codes
- **NPC Witness Reports**: Automated crime reports when NPCs witness crimes
- **Admin Commands**: Full admin tools for manual syncing and lookups

## Requirements

- [QBCore (qb-core)](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [Badger_Discord_API](https://github.com/JaredScar/Badger_Discord_API) (Optional, recommended)
- [NearestPostal](https://forum.cfx.re/t/release-nearest-postal-script/293511) (Optional, recommended)

## Installation

1. Download and extract to your resources folder as `cdecad-sync-qbcore`
2. Configure `shared/config.lua` with your API settings
3. Add `ensure cdecad-sync-qbcore` to your server.cfg (after qb-core and ox_lib)
4. Restart your server

## Configuration

Edit `shared/config.lua`:

```lua
-- API Settings
Config.API_URL = 'https://your-cdecad-instance.com/api'
Config.API_KEY = 'your-fivem-api-key'
Config.COMMUNITY_ID = 'your-discord-guild-id'  -- Your Discord SERVER ID

-- Sync Settings
Config.Sync.OnCharacterLoad = true      -- Sync when player loads character
Config.Sync.OnCharacterCreate = true    -- Sync new characters
Config.Sync.SyncVehicles = true         -- Sync vehicle registrations
```

## Commands

### Player Commands
| Command | Description |
|---------|-------------|
| `/911 [message]` | Send emergency call |
| `/call911` | Interactive 911 call |
| `/911anon [message]` | Anonymous emergency call |
| `/reportstolen` | Report current vehicle stolen |
| `/panic` | Send panic alert (if enabled) |

### Admin Commands
| Command | Description |
|---------|-------------|
| `/cadsync [playerid]` | Force sync a player |
| `/cadsyncall` | Sync all online players |
| `/cadstatus` | Check API connection status |
| `/cadlookup [id/plate]` | Lookup civilian or vehicle |

## QBCore Player Data Structure

This resource uses the standard QBCore player data:

```lua
Player.PlayerData.citizenid           -- Unique character ID
Player.PlayerData.charinfo.firstname  -- First name
Player.PlayerData.charinfo.lastname   -- Last name
Player.PlayerData.charinfo.birthdate  -- Date of birth
Player.PlayerData.charinfo.gender     -- 0 = male, 1 = female
Player.PlayerData.charinfo.nationality
Player.PlayerData.charinfo.phone
```

## Exports

```lua
-- Sync a player's character
exports['cdecad-sync-qbcore']:SyncCharacter(source)

-- Send a 911 call
exports['cdecad-sync-qbcore']:Send911Call(callData)

-- Get synced civilian ID
exports['cdecad-sync-qbcore']:GetSyncedCivilianId(citizenid)

-- Force sync
exports['cdecad-sync-qbcore']:ForceSync(source)
```

## Troubleshooting

### Characters not syncing
1. Check `Config.API_URL` is correct (no trailing slash)
2. Verify `Config.API_KEY` matches your backend's `FIVEM_API_KEY`
3. Ensure `Config.COMMUNITY_ID` is your Discord Server ID (not a user ID)
4. Check F8 console and server console for errors

### 401 Unauthorized
- Your API key doesn't match. Check both FiveM config and backend `.env` file

### Community not found
- Your `Config.COMMUNITY_ID` doesn't match any community's `guildId` in the database
