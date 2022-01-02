QBCore = exports['qb-core']:GetCoreObject()
CreateThread(function()
    while true do 
        if IsControlJustReleased(0,Keys['K']) then 
            TriggerServerEvent('ax-inv:Server:OpenInventory')
        end
        if IsControlJustReleased(0,Keys['G']) then
            local ped = GetPlayerPed(-1) 
            local coords = GetEntityCoords(ped)
            if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                local veh = GetVehiclePedIsIn(ped,false)
                local plate = GetVehicleNumberPlateText(veh):gsub(' ','')
                TriggerServerEvent('ax-inv:Server:OpenInventory','GloveBox-'..plate,{slots=5})
            else 
                local vehicle = QBCore.Functions.GetClosestVehicle()
                if vehicle ~= 0 and vehicle ~= nil then
                    local trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                    end
                    if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunkcoords) < 2.0) and not IsPedInAnyVehicle(ped) then
                        if GetVehicleDoorLockStatus(vehicle) < 2 then
                            local plate = GetVehicleNumberPlateText(vehicle):gsub(' ','')
                            TriggerServerEvent('ax-inv:Server:OpenInventory','Trunk-'..plate,{slots=20})
                            OpenTrunk()
                        else
                            QBCore.Functions.Notify("Vehicle is locked..", "error")
                        end
                    end
                end
            end
        end
        DisableControlAction(0, Keys['TAB'], true)
        if IsDisabledControlJustPressed(0,Keys['TAB']) then
            OpenHotbar()
        end
        for i=1,6 do 
            DisableControlAction(0, Keys[tostring(i)], true)
            if IsDisabledControlJustPressed(0, Keys[tostring(i)]) then
                QBCore.Functions.GetPlayerData(function(PlayerData)
                    if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                        TriggerServerEvent("ax-inv:Server:UseItemSlot", i)
                    end
                end)
            end
        end
        Wait(0)
    end
end)
RegisterNetEvent('ax-inv:Client:OpenInventory')
AddEventHandler('ax-inv:Client:OpenInventory',function(items,other)
    SendNUIMessage({
        action = 'open',
        items = items,
        other = other,
        plyweight = GetPlayerWeight()
    })
    SetNuiFocus(true,true)
end)
RegisterNetEvent('ax-inv:Client:RefreshInventory')
AddEventHandler('ax-inv:Client:RefreshInventory',function(other)
    SendNUIMessage({
        action = 'refresh',
        items = QBCore.Functions.GetPlayerData().items,
        other = other,
        plyweight = GetPlayerWeight()
    })
end)
RegisterNetEvent('ax-inv:Client:CloseInventory')
AddEventHandler('ax-inv:Client:CloseInventory',function()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false,false)
    CloseTrunk()
end)

RegisterNUICallback('SetInventoryData',function(data)
    if not data.toinventory or not data.frominventory then return end
    if string.find(data.frominventory,'Other') or string.find(data.toinventory,'Other') then 
        TriggerServerEvent('ax-inv:Server:SetInventoryData:B/WPlayers',data)
    else
        TriggerServerEvent('ax-inv:Server:SetInventoryData',data)
    end
end)
RegisterNUICallback('CloseInventory',function()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false,false)
    CloseTrunk()
end)
RegisterNUICallback('UseItem',function(data)
    TriggerServerEvent("ax-inv:Server:UseItem",data)
end)
RegisterNUICallback('ChangeVariation',function(data)
    ExecuteCommand(data.component)
end)
RegisterNUICallback('CraftItem', function(data)
    TriggerServerEvent('ax-inv:Server:CraftItem',data)
end)