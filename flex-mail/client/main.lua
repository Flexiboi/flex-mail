local QBCore = exports['qb-core']:GetCoreObject()
local Targets = {}

function CreateBlip(coords)
	local blip = AddBlipForCoord(coords)

	SetBlipSprite(blip, Config.postofficeblip.sprite)
	SetBlipScale(blip, Config.postofficeblip.scale)
	SetBlipColour(blip, Config.postofficeblip.color)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Lang:t("info.blipname"))
	EndTextCommandSetBlipName(blip)

	return blip
end

if Config.mailbox.targetmodel.models ~= nil then
    for k,v in pairs(Config.mailbox.targetmodel.models) do
        exports['qb-target']:AddTargetModel(v, {
            options = {
                {
                    event = "flex-mail:client:openMailbox",
                    icon = Config.mailbox.targetmodel.targeticon,
                    label = Config.mailbox.targetmodel.label,
                }
            },
            distance = Config.mailbox.targetmodel.distance,
        })
    end
end

if Config.mailbox.zones ~= nil then
    for k,v in pairs(Config.mailbox.zones) do
        Targets[k] = exports['qb-target']:AddBoxZone("mailbox"..k, v.coords, v.box.length, v.box.depth, {
            name = "mailbox"..k,
            heading = v.heading,
            debugPoly = Config.debug,
            minZ = v.coords.z + v.box.min,
            maxZ = v.coords.z + v.box.max,
        }, {
            options = {
                {
                    event = "flex-mail:client:openMailbox",
                    icon = v.targeticon,
                    label = v.label,
                }
            },
            distance = v.distance
        })
    end
end

for k,v in pairs(Config.postofficeLocs) do
    CreateBlip(v)
end

local wait = 1
CreateThread(function()
    while true do
        Citizen.Wait(wait)
        local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
        for k,v in pairs(Config.postofficeLocs) do
            local distance = #(playerCoords - v)
            if distance < 2 then
                wait = 1
                QBCore.Functions.DrawText3D(v.x, v.y, v.z, Lang:t("info.deliverenvelop"))
            else
                wait = 1000
            end
        end
    end
end)

RegisterNetEvent('flex-mail:client:useEnvelop', function(id)
    if id then
        local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
        local isnearpostoffice = false
        for k,v in pairs(Config.postofficeLocs) do
        local distance = #(playerCoords - v)
            if distance < 3 then
                isnearpostoffice = true
            end
        end
        QBCore.Functions.TriggerCallback('flex-mail:server:readMail',function(m)
            if m then
                SendNUIMessage({
                    type = 'read',
                    mail = m,
                    nearpostoffice = isnearpostoffice
                })
            end
        end, id)
    else
        SendNUIMessage({
            type = 'write'
        })
    end
    SetNuiFocus(true, true)
end)

RegisterNetEvent('flex-mail:client:openMailbox', function()
    local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict) 
    end
    TaskPlayAnim(GetPlayerPed(-1), animDict, "weed_crouch_checkingleaves_idle_01_inspector", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    QBCore.Functions.TriggerCallback('flex-mail:server:getAllMails',function(mails)
        SendNUIMessage({
            type = 'mailbox',
            maillist = mails
        })
        SetNuiFocus(true, true)
    end)
end)

RegisterNUICallback('CloseNui', function(data, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNUICallback('deleteMail', function(data, cb)
    TriggerServerEvent('flex-mail:server:removemail', data.mailid)
end)

RegisterNUICallback('write', function(data, cb)
    TriggerServerEvent('flex-mail:server:write', data.email, data.subject, data.mailtext)
end)

RegisterNUICallback('sendmail', function(data, cb)
    TriggerServerEvent('flex-mail:server:send', data.mailid)
    SetNuiFocus(false, false)
    ClearPedTasks(GetPlayerPed(-1))
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
    for k,v in pairs(Targets) do
        exports['qb-target']:RemoveZone(Targets[k])
    end
end)