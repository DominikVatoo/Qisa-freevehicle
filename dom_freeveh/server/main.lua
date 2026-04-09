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

local function saveDatabase()
    local ok, encoded = pcall(json.encode, database)
    if not ok then return end
    SaveResourceFile(resName, 'database.json', encoded, -1)
    dirty = false
end

CreateThread(function()
    while true do
        Wait(Config.SaveInterval)
        if dirty then
            saveDatabase()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= resName then return end
    if dirty then saveDatabase() end
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

RegisterCommand(Config.CommandName, function(source)
    if source <= 0 then return end

    local now = GetGameTimer()
    if cooldowns[source] and (now - cooldowns[source]) < Config.CommandCooldown then return end
    cooldowns[source] = now

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local id = xPlayer.identifier
    if database[id] then
        xPlayer.showNotification(Config.Notifications.AlreadyClaimed)
        return
    end

    ExecuteCommand(('_givecar %d %s'):format(source, Config.FreeCar))

    database[id] = os.time()
    dirty = true

    xPlayer.showNotification(Config.Notifications.Success)
    print(('[%s] %s (%s) hat Gratis-Fahrzeug erhalten'):format(resName, xPlayer.getName(), id))
end, false)
