local ESX = exports['es_extended']:getSharedObject()

local resName = GetCurrentResourceName()
local database = {}
local dirty = false
local cooldowns = {}

do
    local raw = LoadResourceFile(resName, 'database.json')
    if raw and raw ~= '' then
        local ok, decoded = pcall(json.decode, raw)
        if ok and type(decoded) == 'table' then
            database = decoded
        else
            print(('[%s] ^1database.json korrupt, starte leer^0'):format(resName))
        end
    end
end

local function flushDatabase()
    local ok, encoded = pcall(json.encode, database)
    if not ok then return end
    SaveResourceFile(resName, 'database.json', encoded, -1)
    dirty = false
end

CreateThread(function()
    while true do
        Wait(QISA.SaveInterval)
        if dirty then
            flushDatabase()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= resName then return end
    if dirty then flushDatabase() end
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

RegisterCommand(QISA.CommandName, function(source)
    if source <= 0 then return end

    local now = GetGameTimer()
    if cooldowns[source] and (now - cooldowns[source]) < QISA.CommandCooldown then return end
    cooldowns[source] = now

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local id = xPlayer.identifier
    if database[id] then
        QISA.Notify(source, 'error', QISA.Notifications.AlreadyClaimed)
        return
    end

    ExecuteCommand(('_givecar %d %s'):format(source, QISA.FreeCar))

    database[id] = os.time()
    dirty = true

    QISA.Notify(source, 'success', QISA.Notifications.Success)
    print(('[%s] %s (%s) hat Gratis-Fahrzeug erhalten'):format(resName, xPlayer.getName(), id))
end, false)
