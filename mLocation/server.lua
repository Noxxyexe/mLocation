ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('mLocation:rentVehicle', function(price, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('mLocation:rentResult', source, true)
    else
        TriggerClientEvent('mLocation:rentResult', source, false)
    end
end)