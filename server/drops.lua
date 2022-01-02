QBCore = exports['qb-core']:GetCoreObject()
Drops = {}
IDs = {}

RegisterNetEvent('ax-inv:DropItem')
AddEventHandler('ax-inv:DropItem',function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    if data then 
        if data.inventory == 'player' then 
            local item = Player.Functions.GetItemBySlot(data.item)
            local id = GenerateDropID()
            if item then 
                Drops[id] = {
                    coords = GetEntityCoords(GetPlayerPed(source)),
                    item = item.name,
                    amount = item.amount,
                    info = item.info
                }
                Player.Functions.RemoveItem(item.name,item.amount,item.slot)
                TriggerClientEvent('ax-inv:GetDrop',-1,Drops)
                TriggerClientEvent('ax-inv:Client:RefreshInventory',src)
            end
        end
    end
end)

RegisterNetEvent('ax-inv:RemoveDrop')
AddEventHandler('ax-inv:RemoveDrop',function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Drops[id] then 
        local item = Drops[id]
        if Player.Functions.AddItem(item.item,item.amount,nil,item.info) then 
            Drops[id] = nil 
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src)
        end
    end
    TriggerClientEvent('ax-inv:GetDrop',-1,Drops)
end)

QBCore.Functions.CreateCallback('ax-inv:GetDrops', function(source,cb)
    cb(Drops)
end)