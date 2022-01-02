local Drops = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('ax-inv:GetDrops', function(cb)
        Drops = cb 
    end)
end)

RegisterNetEvent('ax-inv:GetDrop')
AddEventHandler('ax-inv:GetDrop',function(data)
    Drops = data 
end)

RegisterNUICallback('DropItem',function(data)
    TriggerServerEvent('ax-inv:DropItem',data)
end)

CreateThread(function()
    while true do 
        local sleep = 1500 
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        for k,v in pairs(Drops) do 
            local dist = #(coords-v.coords)
            if dist <= 2 then 
                sleep = 3
                DrawMarker(2, v.coords.x, v.coords.y, v.coords.z-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255,255, 255, 155, false, false, false, 0, false, false, false)
                if IsControlJustReleased(0,38) then 
                    RequestAnimDict("pickup_object")
                    while not HasAnimDictLoaded("pickup_object") do
                        Citizen.Wait(7)
                    end
                    TaskPlayAnim(GetPlayerPed(-1), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
                    Citizen.Wait(2000)
                    ClearPedTasks(GetPlayerPed(-1))
                    TriggerServerEvent('ax-inv:RemoveDrop',k)
                end
            end
        end
        Wait(sleep)
    end
end)