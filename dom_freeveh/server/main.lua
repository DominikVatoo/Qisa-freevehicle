ESX = exports['es_extended']:getSharedObject()

local freeCar = 'i30npriordesign'
local isSaving = false
local database = {}

Citizen.CreateThread(function()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'database.json')
    if raw then
        database = json.decode(raw) or {}
    end
end)

local function saveDatabase()
    while isSaving do
        Citizen.Wait(50)
    end
    isSaving = true
    SaveResourceFile(GetCurrentResourceName(), 'database.json', json.encode(database), -1)
    isSaving = false
end

RegisterCommand('freecar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if database[xPlayer.identifier] then
        xPlayer.showNotification('Du hast bereits ein gratis Auto erhalten!')
        return
    end

    database[xPlayer.identifier] = true
    saveDatabase()

    ExecuteCommand('_givecar ' .. xPlayer.source .. ' ' .. freeCar)
    xPlayer.showNotification('Dominik hat gegönnt! Viel Spaß mit deinem Auto!')
end, false)
