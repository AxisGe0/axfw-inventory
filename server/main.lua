Stashes = {}
QBCore = exports['qb-core']:GetCoreObject()
CreateThread(function()
    while QBCore == nil do 
        Wait(100)
    end
    if QBCore.Functions.ExecuteSql == nil then 
        QBCore.Functions.ExecuteSql = function(ignr,query,cb)
            local data = exports.oxmysql:fetchSync(query)
            if cb ~= nil then
                cb(data)
            end
            return data
        end
    end
end)

RegisterNetEvent('ax-inv:Server:OpenInventory')
AddEventHandler('ax-inv:Server:OpenInventory',function(other,data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local items = Player.PlayerData.items
    local slots = data ~= nil and data.slots ~= nil and data.slots or 54
    if other and Stashes[other] == nil then 
        Stashes[other] = {
            id = other,
            items = GetStashItems(other),
            slots = slots
        }
    end
    TriggerClientEvent('ax-inv:Client:OpenInventory',src,items,Stashes[other])
end)

RegisterNetEvent('ax-inv:Server:OpenPlayerInventory')
AddEventHandler('ax-inv:Server:OpenPlayerInventory',function(other)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(other))
    if Target then 
        local id = 'Other-Player-'..other
        local targetitems = {
            id = id,
            items = Target.PlayerData.items,
            slots = 66
        }
        TriggerClientEvent('ax-inv:Client:OpenInventory',src,Player.PlayerData.items,targetitems)
    end
end)

RegisterNetEvent('ax-inv:Server:SetInventoryData')
AddEventHandler('ax-inv:Server:SetInventoryData',function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if data.frominventory and data.toinventory then
        if data.toinventory == 'player' and data.frominventory == 'player' then
            local fromitem = Player.Functions.GetItemBySlot(data.fromslot)
            if fromitem then
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    local toitem = Player.Functions.GetItemBySlot(data.toslot)
                    Player.Functions.RemoveItem(fromitem.name, amount, data.fromslot)
                    if toitem then
                        if toitem.name ~= fromitem.name then
                            Player.Functions.RemoveItem(toitem.name, toitem.amount, data.toslot)
                            Player.Functions.AddItem(toitem.name, toitem.amount, data.fromslot, toitem.info)
                        end
                    end
                    Player.Functions.AddItem(fromitem.name, amount, data.toslot, fromitem.info) 
                end
            end 
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src)
            print('player to player')
            return
        elseif data.toinventory ~= 'player' and data.frominventory == 'player' then 
            local fromitem = Player.Functions.GetItemBySlot(data.fromslot)
            if fromitem then
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    local toitem = Stashes[data.toinventory].items[data.toslot]
                    Player.Functions.RemoveItem(fromitem.name,amount,data.fromslot)
                    if toitem then 
                        if toitem.name ~= fromitem.name then
                            Player.Functions.AddItem(toitem.name,toitem.amount,fromitem.slot,toitem.info)
                            RemoveItemFromStash(data.toinventory,toitem.name,toitem.amount,toitem.slot)
                        end
                    end
                    AddItemToStash(data.toinventory,fromitem.name,amount,data.toslot,fromitem.info)
                end
            end
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src,Stashes[data.toinventory])
            print('player to stash')
            return
        elseif data.frominventory ~= 'player' and data.toinventory == 'player' then
            local fromitem = Stashes[data.frominventory].items[data.fromslot]
            if fromitem then
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    if(CanCarryItem(src,fromitem.name,amount)) then
                        local toitem = Player.Functions.GetItemBySlot(data.toslot)
                        RemoveItemFromStash(data.frominventory,fromitem.name,amount,fromitem.slot)
                        if toitem then
                            if toitem.name ~= fromitem.name then
                                Player.Functions.RemoveItem(toitem.name,toitem.amount,toitem.slot)
                                AddItemToStash(data.frominventory,toitem.name,toitem.amount,fromitem.slot,toitem.info)
                            end
                        end
                        Player.Functions.AddItem(fromitem.name,amount,data.toslot,fromitem.info)
                    end
                end
            end
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src,Stashes[data.frominventory])
            print('stash to player')
            return
        elseif data.frominventory ~= 'player' and data.toinventory ~= 'player' then
            local fromitem = Stashes[data.frominventory].items[data.fromslot]
            if fromitem then 
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    local toitem = Stashes[data.frominventory].items[data.toslot]
                    local toitemamount;if toitem then toitemamount = Stashes[data.frominventory].items[data.toslot].amount end
                    RemoveItemFromStash(data.frominventory,fromitem.name,amount,fromitem.slot)
                    if toitem then 
                        if toitem.name ~= fromitem.name then
                            RemoveItemFromStash(data.frominventory,toitem.name, toitemamount, toitem.slot)
                            AddItemToStash(data.frominventory,toitem.name, toitemamount, fromitem.slot,toitem.info)
                        end
                    end
                    AddItemToStash(data.frominventory,fromitem.name,amount,data.toslot,fromitem.info)
                end
            end
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src,Stashes[data.frominventory])
            print('stash to stash')
            return 
        end
    end
end)

RegisterNetEvent('ax-inv:Server:SetInventoryData:B/WPlayers')
AddEventHandler('ax-inv:Server:SetInventoryData:B/WPlayers',function(data)
    if not data.frominventory or not data.toinventory then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = GetNumberFromString(data.frominventory) ~= nil and GetNumberFromString(data.frominventory) or GetNumberFromString(data.toinventory) ~= nil and GetNumberFromString(data.toinventory)
    local TargetPlayer = QBCore.Functions.GetPlayer(Target)
    if not TargetPlayer then return end
    if data.frominventory == 'player' and data.toinventory ~= 'player' then 
        local fromitem = Player.Functions.GetItemBySlot(data.fromslot)
        if fromitem then
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = TargetPlayer.Functions.GetItemBySlot(data.toslot)
                Player.Functions.RemoveItem(fromitem.name, amount, data.fromslot)
                if toitem then
                    if toitem.name ~= fromitem.name then
                        TargetPlayer.Functions.RemoveItem(toitem.name, toitem.amount, data.toslot)
                        Player.Functions.AddItem(toitem.name, toitem.amount, data.fromslot, toitem.info)
                    end
                end
                TargetPlayer.Functions.AddItem(fromitem.name, amount, data.toslot, fromitem.info) 
            end
        end 
        print('Player to OtherPlayer')
        TriggerClientEvent('ax-inv:Client:RefreshInventory',src,{id = data.toinventory,items = QBCore.Functions.GetPlayer(Target).PlayerData.items,slots = 54})
    elseif data.frominventory ~= 'player' and data.toinventory == 'player' then 
        local fromitem = TargetPlayer.Functions.GetItemBySlot(data.fromslot)
        if fromitem then
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = Player.Functions.GetItemBySlot(data.toslot)
                TargetPlayer.Functions.RemoveItem(fromitem.name, amount, data.fromslot)
                if toitem then
                    if toitem.name ~= fromitem.name then
                        Player.Functions.RemoveItem(toitem.name, toitem.amount, data.toslot)
                        TargetPlayer.Functions.AddItem(toitem.name, toitem.amount, data.fromslot, toitem.info)
                    end
                end
                Player.Functions.AddItem(fromitem.name, amount, data.toslot, fromitem.info) 
            end
        end 
        print('OtherPlayer to Player')
        TriggerClientEvent('ax-inv:Client:RefreshInventory',src,{id = data.frominventory,items = QBCore.Functions.GetPlayer(Target).PlayerData.items,slots = 54})
    elseif data.frominventory ~= 'player' and data.toinventory ~= 'player' then 
        local fromitem = TargetPlayer.Functions.GetItemBySlot(data.fromslot)
        if fromitem then
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = TargetPlayer.Functions.GetItemBySlot(data.toslot)
                TargetPlayer.Functions.RemoveItem(fromitem.name, amount, data.fromslot)
                if toitem then
                    if toitem.name ~= fromitem.name then
                        TargetPlayer.Functions.RemoveItem(toitem.name, toitem.amount, data.toslot)
                        TargetPlayer.Functions.AddItem(toitem.name, toitem.amount, data.fromslot, toitem.info)
                    end
                end
                TargetPlayer.Functions.AddItem(fromitem.name, amount, data.toslot, fromitem.info) 
            end
        end 
        print('Other-Inv to Other-Inv')
        TriggerClientEvent('ax-inv:Client:RefreshInventory',src,{id = data.frominventory,items = QBCore.Functions.GetPlayer(Target).PlayerData.items,slots = 54})
    end
end)

RegisterServerEvent("ax-inv:Server:UseItem")
AddEventHandler('ax-inv:Server:UseItem', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if data.inventory == "player" then
		local itemdata = Player.Functions.GetItemBySlot(data.item)
		if itemdata ~= nil then
			TriggerClientEvent("QBCore:Client:UseItem", src, itemdata)
            TriggerClientEvent('ax-inv:Client:RefreshInventory',src)
            if QBCore.Shared.Items[itemdata.name:lower()]['shouldClose'] then 
                TriggerClientEvent('ax-inv:Client:CloseInventory',src)
            end
		end
	end
end)

RegisterServerEvent("ax-inv:Server:UseItemSlot")
AddEventHandler('ax-inv:Server:UseItemSlot', function(slot)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local itemdata = Player.Functions.GetItemBySlot(slot)
	if itemdata then
		local iteminfo = QBCore.Shared.Items[itemdata.name]
		if itemdata.type == "weapon" then
			if itemdata.info.quality ~= nil then
				if itemdata.info.quality > 0 then
					TriggerClientEvent("inventory:client:UseWeapon", src, itemdata, true)
				else
					TriggerClientEvent("inventory:client:UseWeapon", src, itemdata, false)
				end
			else
				TriggerClientEvent("inventory:client:UseWeapon", src, itemdata, true)
			end
		elseif itemdata.useable then
			TriggerClientEvent("QBCore:Client:UseItem", src, itemdata)
		end
	end
end)

RegisterNetEvent('ax-inv:Server:CraftItem')
AddEventHandler('ax-inv:Server:CraftItem',function(data)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local retval = true
    if data then 
        if data.item and data.recipe then 
            for k,v in pairs(data.recipe) do 
                if Player.Functions.GetItemByName(v.name) then 
                    if Player.Functions.GetItemByName(v.name).amount < v.amount then 
                        retval = false 
                    end
                else
                    retval = false
                end
            end
        end
    end
    if retval and data.item then 
        for k,v in pairs(data.recipe) do 
            Player.Functions.RemoveItem(v.name,v.amount)
        end
        Player.Functions.AddItem(data.item,1)
        TriggerClientEvent('ax-inv:Client:CloseInventory',src)
    end
end)