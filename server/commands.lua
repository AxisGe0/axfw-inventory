QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('openinv','Open Inventory of a player',{name='id',help='Player ID'},true,function(source,args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if Target then 
		local id = 'Other-Player-'..args[1]
		local targetitems = {
			id = id,
			items = Target.PlayerData.items,
			slots = 66
		}
		TriggerClientEvent('ax-inv:Client:OpenInventory',src,Player.PlayerData.items,targetitems)
	end
end,'admin')

QBCore.Commands.Add("giveitem", "Give item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	local amount = tonumber(args[3])
	local itemData = QBCore.Shared.Items[tostring(args[2]):lower()]
	if Player ~= nil then
		if amount > 0 then
			if itemData ~= nil then
				local info = {}
				if itemData["name"] == "id_card" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.nationality = Player.PlayerData.charinfo.nationality
					info.job = Player.PlayerData.job.label
				elseif itemData["type"] == "weapon" then
					amount = 1
					info.serie = tostring(math.random(100000,9000000))..tostring(math.random(100000,900000))..tostring(math.random(100000,900000))..tostring(math.random(100000,900000))
				end
				if Player.Functions.AddItem(itemData["name"], amount, false, info) then
					TriggerClientEvent('QBCore:Notify', source, "You have given " ..GetPlayerName(tonumber(args[1])).." " .. itemData["name"] .. " ("..amount.. ")", "success")
				else
					TriggerClientEvent('QBCore:Notify', source,  "Can't give item!", "error")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Item doesn't exist!")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Amount must be higher than 0!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")