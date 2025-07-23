local Framework = nil
local robCooldowns = {}
local targetCooldowns = {}
local activeRobberies = {}
local currentTime = os.time() * 1000

local Webhooks = {
    Enable = true,
    URL = "https://discord.com/api/webhooks/1317942551445241976/g0-U9IIKKI0avc6LyrGBZWuna8J6reEaUW9c39qNAI67nvB6anXsB_F2NYBPW8BmOkWp",
    BotName = "FearX-OxRobV2 Security",
    BotAvatar = "https://cdn.discordapp.com/attachments/123456789/avatar.png"
}

local function CheckESXExport()
    local resource = GetResourceMetadata('es_extended', 'export', 0)
    if resource and resource == 'getSharedObject' then
        return true
    end
    return false
end

local function InitializeFramework()
    if Config.Framework == 'qbcore' or Config.Framework == 'qb-core' then
        if GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
            print('^2[FEARX-OXROB-V2] QBCore Framework loaded (manual config)^0')
        else
            print('^1[FEARX-OXROB-V2] QBCore not found but set in config^0')
        end
    elseif Config.Framework == 'qbx' or Config.Framework == 'qbx_core' then
        if GetResourceState('qbx_core') == 'started' then
            Framework = exports.qbx_core
            print('^2[FEARX-OXROB-V2] QBX Framework loaded (manual config)^0')
        else
            print('^1[FEARX-OXROB-V2] QBX not found but set in config^0')
        end
    elseif Config.Framework == 'esx' or Config.Framework == 'es_extended' then
        if GetResourceState('es_extended') == 'started' then
            if CheckESXExport() then
                Framework = exports['es_extended']:getSharedObject()
                print('^2[FEARX-OXROB-V2] ESX Framework loaded (manual config - new version)^0')
            else
                local esxReceived = false
                TriggerEvent('esx:getSharedObject', function(obj) 
                    Framework = obj 
                    esxReceived = true
                end)
                local timeout = 0
                while not esxReceived and timeout < 30 do
                    Wait(100)
                    timeout = timeout + 1
                end
                if Framework then
                    print('^2[FEARX-OXROB-V2] ESX Framework loaded (manual config - legacy version)^0')
                else
                    print('^1[FEARX-OXROB-V2] ESX detected but failed to initialize^0')
                end
            end
        else
            print('^1[FEARX-OXROB-V2] ESX not found but set in config^0')
        end
    elseif Config.Framework == 'standalone' or Config.Framework == 'none' then
        print('^3[FEARX-OXROB-V2] Running in standalone mode (manual config)^0')
    elseif Config.Framework == 'auto' then
        if GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
            print('^2[FEARX-OXROB-V2] QBCore Framework detected (auto)^0')
        elseif GetResourceState('qbx_core') == 'started' then
            Framework = exports.qbx_core
            print('^2[FEARX-OXROB-V2] QBX Framework detected (auto)^0')
        elseif GetResourceState('es_extended') == 'started' then
            if CheckESXExport() then
                Framework = exports['es_extended']:getSharedObject()
                print('^2[FEARX-OXROB-V2] ESX Framework detected (auto - new version)^0')
            else
                local esxReceived = false
                TriggerEvent('esx:getSharedObject', function(obj) 
                    Framework = obj 
                    esxReceived = true
                end)
                local timeout = 0
                while not esxReceived and timeout < 30 do
                    Wait(100)
                    timeout = timeout + 1
                end
                if Framework then
                    print('^2[FEARX-OXROB-V2] ESX Framework detected (auto - legacy version)^0')
                else
                    print('^1[FEARX-OXROB-V2] ESX detected but failed to initialize^0')
                end
            end
        else
            print('^3[FEARX-OXROB-V2] No framework detected, running in standalone mode^0')
        end
    else
        print('^1[FEARX-OXROB-V2] Invalid framework setting in config: ' .. Config.Framework .. '^0')
        print('^3[FEARX-OXROB-V2] Valid options: auto, qbcore, qbx, esx, standalone^0')
    end
end

CreateThread(function()
    InitializeFramework()
end)

local function SendWebhook(title, description, color, fields)
    if not Webhooks.Enable or not Webhooks.URL then
        print("^3[FEARX-OXROB-V2] Webhooks disabled or URL not set^0")
        return
    end
    
    local embed = {
        title = title,
        description = description,
        color = color or 16711680,
        fields = fields or {},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        footer = {
            text = "FearX-OxRobV2 Security System"
        }
    }
    
    local payload = {
        username = Webhooks.BotName,
        embeds = {embed}
    }
    
    PerformHttpRequest(Webhooks.URL, function(statusCode, response, headers)
        if statusCode == 200 or statusCode == 204 then
            print("^2[FEARX-OXROB-V2] Webhook sent successfully^0")
        else
            print("^1[FEARX-OXROB-V2] Webhook failed with status: " .. statusCode .. "^0")
            print("^1Response: " .. tostring(response) .. "^0")
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

local function LogExploit(playerId, playerName, targetId, distance, maxDistance, playerCoords, targetCoords)
    local playerIdentifiers = {}
    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local identifier = GetPlayerIdentifier(playerId, i)
        if identifier then
            local idType = string.match(identifier, "^([^:]+):")
            if idType == "steam" or idType == "license" or idType == "discord" then
                table.insert(playerIdentifiers, identifier)
            end
        end
    end
    
    local identifiersText = #playerIdentifiers > 0 and table.concat(playerIdentifiers, "\\n") or "No identifiers found"
    
    local fields = {
        {
            name = "🚨 Exploit Type",
            value = "Distance Robbery Exploit",
            inline = true
        },
        {
            name = "📏 Distance",
            value = string.format("%.1fm (Max: %.1fm)", distance, maxDistance),
            inline = true
        },
        {
            name = "⚡ Excess",
            value = string.format("%.1fm over limit", distance - maxDistance),
            inline = true
        },
        {
            name = "👤 Exploiter",
            value = string.format("**%s** (ID: %s)", playerName, playerId),
            inline = true
        },
        {
            name = "🎯 Target",
            value = string.format("**%s** (ID: %s)", GetPlayerName(targetId) or "Unknown", targetId),
            inline = true
        },
        {
            name = "🔍 Player Identifiers",
            value = identifiersText,
            inline = false
        }
    }
    
    SendWebhook(
        "🚨 ROBBERY EXPLOIT DETECTED",
        string.format("**%s** tried to rob someone from **%.1f meters** away!\\n\\n✅ Player automatically kicked from server", playerName, distance),
        16711680,
        fields
    )
end

local function LogAntiCheat(playerId, playerName, violationType, details)
    local playerIdentifiers = {}
    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local identifier = GetPlayerIdentifier(playerId, i)
        if identifier then
            local idType = string.match(identifier, "^([^:]+):")
            if idType == "steam" or idType == "license" or idType == "discord" then
                table.insert(playerIdentifiers, identifier)
            end
        end
    end
    
    local identifiersText = #playerIdentifiers > 0 and table.concat(playerIdentifiers, "\\n") or "No identifiers found"
    
    local fields = {
        {
            name = "⚠️ Violation Type",
            value = violationType,
            inline = true
        },
        {
            name = "👤 Player",
            value = string.format("**%s** (ID: %s)", playerName, playerId),
            inline = true
        },
        {
            name = "🔍 Player Identifiers",
            value = identifiersText,
            inline = false
        }
    }
    
    SendWebhook(
        "⚠️ ANTI-CHEAT VIOLATION",
        string.format("**%s** triggered anti-cheat protection", playerName),
        16776960,
        fields
    )
end

CreateThread(function()
    while true do
        currentTime = os.time() * 1000
        Wait(30000)
    end
end)

local function IsPlayerOnCooldown(playerId)
    return robCooldowns[playerId] and currentTime < robCooldowns[playerId]
end

local function IsTargetOnCooldown(targetId)
    return targetCooldowns[targetId] and currentTime < targetCooldowns[targetId]
end

local function SetCooldowns(robberId, targetId)
    local cooldownTime = currentTime + (Config.RobCooldown * 1000)
    robCooldowns[robberId] = cooldownTime
    targetCooldowns[targetId] = cooldownTime
end

local function ValidateRobbery(src, targetId)
    if IsPlayerOnCooldown(src) then
        TriggerClientEvent('fearx-oxrob:client:notify', src, 'rob_cooldown', 'error')
        return false
    end
    
    if IsTargetOnCooldown(targetId) then
        TriggerClientEvent('fearx-oxrob:client:notify', src, 'target_cooldown', 'error')
        return false
    end
    
    local targetPing = GetPlayerPing(targetId)
    if not targetPing or targetPing == 0 then
        TriggerClientEvent('fearx-oxrob:client:notify', src, 'no_target', 'error')
        return false
    end
    
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    local distance = #(srcCoords - targetCoords)
    
    if distance > Config.RobDistance then
        local playerName = GetPlayerName(src)
        print(('FEARX-OXROB-V2 EXPLOIT: Player %s (%s) tried to rob Player %s from distance %.2f (Max: %.2f)'):format(src, playerName, targetId, distance, Config.RobDistance))
        
        LogExploit(src, playerName, targetId, distance, Config.RobDistance, srcCoords, targetCoords)
        
        TriggerClientEvent('fearx-oxrob:client:notify', targetId, 'exploit_attempt', 'error')
        DropPlayer(src, 'FEARX-OXROB-V2: Distance exploit attempt')
        return false
    end
    
    return true
end

RegisterNetEvent('fearx-oxrob:server:startRob', function(targetId)
    local src = source
    
    if not ValidateRobbery(src, targetId) then return end
    
    activeRobberies[src] = {target = targetId, startTime = currentTime}
    SetCooldowns(src, targetId)
    
    TriggerClientEvent('fearx-oxrob:client:beingRobbed', targetId)
end)

RegisterNetEvent('fearx-oxrob:server:cancelRob', function(targetId)
    activeRobberies[source] = nil
end)

RegisterNetEvent('fearx-oxrob:server:targetHandsDown', function(targetId)
    local src = source
    for robberId, data in pairs(activeRobberies) do
        if data.target == src then
            TriggerClientEvent('fearx-oxrob:client:notify', robberId, 'target_hands_down', 'error')
            TriggerClientEvent('fearx-oxrob:client:cancelRobbery', robberId)
            activeRobberies[robberId] = nil
        end
    end
end)

RegisterNetEvent('fearx-oxrob:server:anticheat', function(violationType)
    local src = source
    local playerName = GetPlayerName(src)
    print(('FEARX-OXROB-V2 ANTICHEAT: Player %s violated %s'):format(src, violationType))
    
    LogAntiCheat(src, playerName, violationType, 'Player triggered anti-cheat during robbery')
    
    DropPlayer(src, 'FEARX-OXROB-V2: Anticheat violation - ' .. violationType)
end)

AddEventHandler('playerDropped', function()
    local src = source
    robCooldowns[src] = nil
    targetCooldowns[src] = nil
    activeRobberies[src] = nil
end)