QISA = {}

QISA.FreeCar = 'i30npriordesign'
QISA.CommandName = 'freecar'
QISA.SaveInterval = 30000
QISA.CommandCooldown = 5000

QISA.Notifications = {
    AlreadyClaimed = 'Du hast bereits ein gratis Auto erhalten!',
    Success        = 'Dominik hat gegönnt! Viel Spaß mit deinem Auto!',
    Error          = 'Fehler beim Vergeben des Fahrzeugs. Melde dich im Support.',
}

if not IsDuplicityVersion() then
    QISA.Notify = function(type, message)
        exports['es_extended']:getSharedObject().ShowNotification(message)
    end
else
    QISA.Notify = function(src, type, message)
        TriggerClientEvent('esx:showNotification', src, message)
    end
end
