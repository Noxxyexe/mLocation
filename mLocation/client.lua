ESX = exports['es_extended']:getSharedObject()

local pedCoords = Config.PedCoords
local pedModel = Config.PedModel
local ped = nil

Citizen.CreateThread(function()
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end
    ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    local blip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
    SetBlipSprite(blip, Config.Blips.Sprite)
    SetBlipDisplay(blip, Config.Blips.Display)
    SetBlipScale(blip, Config.Blips.Scale)
    SetBlipColour(blip, Config.Blips.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blips.Name)
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local targetCoords = vector3(Config.PointCoords.x, Config.PointCoords.y, Config.PointCoords.z)
        local dist = #(playerCoords - targetCoords)

        if dist < 3.0 then
            sleep = 1
            ESX.ShowHelpNotification(Config.Text)
            if IsControlJustPressed(0, 38) then
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "open",
                    vehicles = Config.Vehicles
                })
            end
        end

        Wait(sleep)
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

local RentRequest = nil

RegisterNUICallback('rent', function(data, cb)
    local model = data.model
    local vehicleData = nil
    for _, v in ipairs(Config.Vehicles) do
        if v.model == model then
            vehicleData = v
            break
        end
    end
    if not vehicleData then
        ESX.ShowNotification('Vehicle not found in config!')
        SetNuiFocus(false, false)
        cb('fail')
        return
    end
    local playerPed = PlayerPedId()
    local spawnPoint = nil
    for _, point in ipairs(Config.SpawnPoints) do
        local vehicles = ESX.Game.GetVehiclesInArea(vector3(point.x, point.y, point.z), 3.0)
        if #vehicles == 0 then
            spawnPoint = point
            break
        end
    end
    if not spawnPoint then
        ESX.ShowNotification('No available spawn point for vehicles!')
        SetNuiFocus(false, false)
        cb('fail')
        return
    end
    RentRequest = {model = model, spawnPoint = spawnPoint, cb = cb}
    TriggerServerEvent('mLocation:rentVehicle', vehicleData.price)
end)

RegisterNetEvent('mLocation:rentResult')
AddEventHandler('mLocation:rentResult', function(success)
    if not RentRequest then return end
    local model = RentRequest.model
    local spawnPoint = RentRequest.spawnPoint
    local playerPed = PlayerPedId()
    if success then
        ESX.Game.SpawnVehicle(model, vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), spawnPoint.w, function(vehicle)
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        end)
        ESX.ShowNotification('You have successfully rented your vehicle!')
    else
        ESX.ShowNotification('You do not have enough money to rent this vehicle!')
    end
    SetNuiFocus(false, false)
    if RentRequest.cb then RentRequest.cb('ok') end
    RentRequest = nil
end)