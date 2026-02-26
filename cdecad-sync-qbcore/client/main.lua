--[[
    CDECAD Sync - Main Client Script for QBCore
    Handles client-side notifications and data gathering
]]

-- Get QBCore object
local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}
local isLoggedIn = false

-- =============================================================================
-- PLAYER DATA MANAGEMENT
-- =============================================================================

-- Get player data
local function GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

-- Update local player data cache
local function UpdatePlayerData()
    PlayerData = GetPlayerData() or {}
    isLoggedIn = PlayerData.citizenid ~= nil
end

-- =============================================================================
-- EVENT HANDLERS
-- =============================================================================

-- Player loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    UpdatePlayerData()
    Utils.Debug('Client: Player loaded')
end)

-- Player unloaded
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
    Utils.Debug('Client: Player logged out')
end)

-- Player data updated
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================

RegisterNetEvent('cdecad-sync:client:notify', function(type, message)
    if Config.Notifications.UseOxLib then
        lib.notify({
            title = 'CDECAD',
            description = message,
            type = type,
            duration = Config.Notifications.Duration,
            position = Config.Notifications.Position
        })
    else
        -- QBCore native notifications
        QBCore.Functions.Notify(message, type, Config.Notifications.Duration)
    end
end)

-- =============================================================================
-- LOCATION HELPERS
-- =============================================================================

-- Get current street name
function GetCurrentStreetName()
    local coords = GetEntityCoords(PlayerPedId())
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossingName = GetStreetNameFromHashKey(crossingHash)
    
    if crossingName and crossingName ~= '' then
        return streetName .. ' & ' .. crossingName
    end
    return streetName
end

-- Get current zone name
function GetCurrentZoneName()
    local coords = GetEntityCoords(PlayerPedId())
    return GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
end

-- Get location info for 911 calls
function GetLocationInfo()
    local coords = GetEntityCoords(PlayerPedId())
    local street = GetCurrentStreetName()
    local zone = GetCurrentZoneName()
    
    -- Try to get postal if available
    local postal = nil
    if exports['nearest-postal'] then
        postal = exports['nearest-postal']:getPostal()
    elseif exports['qb-postal'] then
        postal = exports['qb-postal']:getPostal()
    end
    
    return {
        street = street,
        zone = zone,
        postal = postal,
        coords = coords,
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

-- Get current vehicle info
function GetCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        return nil
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    
    return {
        vehicle = vehicle,
        plate = plate:gsub('%s+', ''),
        model = displayName,
        class = GetVehicleClass(vehicle)
    }
end

-- =============================================================================
-- 911 CALL PREPARATION
-- =============================================================================

-- Prepare 911 call data
function Prepare911CallData(callType, anonymous)
    local location = GetLocationInfo()
    
    return {
        callType = callType,
        location = location.street .. ', ' .. location.zone,
        street = location.street,
        zone = location.zone,
        postal = location.postal,
        coords = location.coords,
        anonymous = anonymous or false
    }
end

-- =============================================================================
-- EXPORTS
-- =============================================================================

exports('GetLocationInfo', GetLocationInfo)
exports('GetCurrentVehicle', GetCurrentVehicle)
exports('Prepare911CallData', Prepare911CallData)

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

CreateThread(function()
    -- Wait for QBCore to be ready
    while not QBCore do
        Wait(100)
    end
    
    -- Wait for player to be fully loaded
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(500)
    end
    
    UpdatePlayerData()
    Utils.Debug('Client: Initialized (QBCore)')
end)

print('[CDECAD-SYNC] Client script loaded (QBCore)')
