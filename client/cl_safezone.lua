local ESX = exports['es_extended']:getSharedObject()
local spawnedNpcs = {}

local function CreateBlipForZone(zone)
    if zone.showblip then
        zone.blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.blipradius)
        SetBlipSprite(zone.blip, zone.blipsprite)
        SetBlipScale(zone.blip, zone.blipscale)
        SetBlipColour(zone.blip, zone.blipcolor)
        SetBlipAsShortRange(zone.blip, true)

        zone.blipName = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(zone.blipName, zone.blipsprite)
        SetBlipDisplay(zone.blipName, 4)
        SetBlipScale(zone.blipName, zone.blipscale)
        SetBlipColour(zone.blipName, zone.blipcolor)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.blipname)
        EndTextCommandSetBlipName(zone.blipName)
    end
end

local function SpawnNPCInZone(zone, pos)
    local model = joaat(zone.npcs.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local npc = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, true, true)
    
    SetEntityInvincible(npc, zone.npcs.invincible)
    FreezeEntityPosition(npc, zone.npcs.freeze)
    SetPedCanBeTargetted(npc, true)
    SetPedFleeAttributes(npc, 0, true)
    SetPedCombatAttributes(npc, 46, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    GiveWeaponToPed(npc, joaat(zone.npcs.weapons[1]), 250, false, true)

    table.insert(spawnedNpcs, {
        entity = npc,
        zone = zone,
        originalPos = pos,
        isInCombat = false
    })
end


local function SpawnNPCsInZone(zone)
    zone.deadCount = 0
    for _, pos in ipairs(zone.npcs.positions) do
        local distance = #(zone.coords - vector3(pos.x, pos.y, pos.z))
        if distance <= zone.radius then
            SpawnNPCInZone(zone, pos)
        end
    end
end

local function ResetNPCs(zone)
    for _, npcData in ipairs(spawnedNpcs) do
        if npcData.zone == zone then
            local npc = npcData.entity
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
                collectgarbage('collect')
            end
        end
    end

    spawnedNpcs = {}
    zone.deadCount = 0
end

local function OnEnterSafeZone(point, zone)
    if not zone.npcs.spawned and not zone.npcs.isRespawning then
        print("Generando NPCs en la zona:", zone.blipname)
        SpawnNPCsInZone(zone)
        zone.npcs.spawned = true
    end

    ESX.ShowNotification('Entraste en la zona segura: ' .. zone.blipname)
end

local function OnExitSafeZone(point, zone)
    print("Saliste de la zona segura:", zone.blipname)
    ESX.ShowNotification('Saliste de la zona segura: ' .. zone.blipname)
    ResetNPCs(zone)
    zone.npcs.spawned = false
end

local function RespawnNPCsAfterDeath(zone)
    if not zone.npcs.isRespawning then

        zone.npcs.isRespawning = true
        ESX.ShowNotification('Los policías de guardia en la ' .. zone.blipname .. ' fueron heridos y volverán dentro de 1 minuto.')
        
        ResetNPCs(zone)
        Wait(zone.npcs.respawn)
        
        SpawnNPCsInZone(zone)
        ESX.ShowNotification('Los policías de la ' .. zone.blipname .. ' han vuelto a su lugar.')
        
        zone.npcs.isRespawning = false
        zone.npcs.spawned = true
    end
end

local function ActivateNPCsIfInCombat(playerPed, zone)
    local playerWeapon = GetSelectedPedWeapon(playerPed)
    local isPlayerShooting = IsPedShooting(playerPed)
    local isPlayerMeleeAttacking = IsPedPerformingMeleeAction(playerPed)
    local isPlayerArmed = playerWeapon ~= GetHashKey("WEAPON_UNARMED")

    if (isPlayerShooting or isPlayerMeleeAttacking) and isPlayerArmed then
        for _, npcData in ipairs(spawnedNpcs) do
            if npcData.zone == zone and not npcData.isInCombat then
                local npc = npcData.entity
                local npcPos = GetEntityCoords(npc)
                local distance = #(npcPos - zone.coords)

                if distance <= zone.radius then
                    npcData.isInCombat = true
                    SetEntityInvincible(npc, false)
                    FreezeEntityPosition(npc, false)

                    SetPedAsEnemy(npc, true)
                    TaskCombatPed(npc, playerPed, 0, 16)
                    SetPedDropsWeaponsWhenDead(npc, false)
                    print("NPC ahora es vulnerable y está atacando")
                end
            end
        end
    end
end


local function ClearNPCs()
    for _, data in ipairs(spawnedNpcs) do
        if DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
            collectgarbage('collect')
        end
    end
    spawnedNpcs = {}
end

local function SpawnSafeZoneNPCs()
    for _, zone in pairs(ConfigNPC.SafeZonesNpc) do
        zone.npcs.isRespawning = false
        local point = lib.points.new({
            coords = zone.coords,
            distance = zone.radius,
            onEnter = function() OnEnterSafeZone(point, zone) end,
            onExit = function() OnExitSafeZone(point, zone) end
        })

        CreateBlipForZone(zone)
    end
end

local function ResetNPCsToSpawn()
    for _, npcData in ipairs(spawnedNpcs) do
        local npc = npcData.entity
        local pos = npcData.originalPos

        SetEntityCoords(npc, pos.x, pos.y, pos.z, false, false, false, true)
        ClearPedTasks(npc)
        FreezeEntityPosition(npc, npcData.zone.npcs.freeze)
        SetEntityInvincible(npc, npcData.zone.npcs.invincible)
        npcData.isInCombat = false
    end
end

CreateThread(function()
    while true do
        Wait(500)
        for _, npcData in ipairs(spawnedNpcs) do
            local npc = npcData.entity
            local zone = npcData.zone

            if DoesEntityExist(npc) and IsEntityDead(npc) then
                zone.deadCount = zone.deadCount + 1
                Wait(1500)

                if DoesEntityExist(npc) then
                    DeleteEntity(npc)
                    npcData.entity = nil
                end

                if zone.deadCount >= #zone.npcs.positions then
                    RespawnNPCsAfterDeath(zone)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(50)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        for _, zone in pairs(ConfigNPC.SafeZonesNpc) do
            local point = lib.points.getClosestPoint()

            if point and point.coords then
                local distance = #(playerPos - point.coords)
                if distance <= zone.radius then
                    ActivateNPCsIfInCombat(playerPed, zone)
                end
            end
        end
    end
end)


AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SpawnSafeZoneNPCs()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ClearNPCs()
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    ResetNPCsToSpawn()
end)