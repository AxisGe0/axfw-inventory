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

GenerateDropID = function()
    local id = 'Drop-'..math.random(10000,60000)
    while IDs[id] do 
        Wait(0)
        id = 'Drop-'..math.random(10000,60000)
    end
    IDs[id] = true
    return id
end

AddItemToStash = function(id,item,amount,slot,info)
    local iteminfo = QBCore.Shared.Items[item:lower()]
    if Stashes[id] then 
        if slot then 
            if Stashes[id].items[slot] and Stashes[id].items[slot].name == item then 
                if iteminfo.unique or iteminfo.type == 'weapon' then 
                    local freeslot = GetFreeSlot(id)
                    Stashes[id].items[freeslot] = {
                        name = item,
                        slot = freeslot,
                        image = QBCore.Shared.Items[item].image,
                        amount = tonumber(amount),
                        info = info,
                        type = QBCore.Shared.Items[item:lower()]['type'],
                        label = QBCore.Shared.Items[item:lower()]['label']
                    }
                else
                    Stashes[id].items[slot].amount = Stashes[id].items[slot].amount + amount 
                end
            else
                Stashes[id].items[slot] = {
                    name = item,
                    slot = slot,
                    image = QBCore.Shared.Items[item].image,
                    amount = tonumber(amount),
                    info = info,
                    type = QBCore.Shared.Items[item:lower()]['type'],
                    label = QBCore.Shared.Items[item:lower()]['label']
                }
            end
        else 
            table.insert(Stashes[id].items,{
                name = item,
                slot = slot,
                image = QBCore.Shared.Items[item].image,
                amount = tonumber(amount),
                info = info,
                label = QBCore.Shared.Items[item:lower()]['label']
            })
        end
        SaveStash(id,Stashes[id].items)
    end
end

RemoveItemFromStash = function(id,item,amount,slot)
    if Stashes[id] then 
        if slot then 
            if Stashes[id].items[slot] and Stashes[id].items[slot].name == item then 
                Stashes[id].items[slot].amount = Stashes[id].items[slot].amount - amount 
                if Stashes[id].items[slot].amount <= 0 then 
                    Stashes[id].items[slot] = nil 
                end
            else
                Stashes[id].items[slot] = nil
            end
        end
        SaveStash(id,Stashes[id].items)
    end
end

SaveStash = function(id,items)
    if items and id then 
        if Stashes[id] then
            QBCore.Functions.ExecuteSql(false, "SELECT * FROM `inventories` WHERE `id` = '"..id.."'", function(result)
                if result[1] ~= nil then
                    QBCore.Functions.ExecuteSql(false, "UPDATE `inventories` SET `data` = '"..json.encode(items).."' WHERE `id` = '"..id.."'")
                else
                    QBCore.Functions.ExecuteSql(false, "INSERT INTO `inventories` (`id`, `data`) VALUES ('"..id.."', '"..json.encode(items).."')")
                end
            end)
        end
    end
end

GetStashItems = function(id) 
    local items = {}
    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `inventories` WHERE `id` = '"..id.."'", function(result)
        if result[1] then 
            result[1] = json.decode(result[1].data)
            if result[1] then 
                for k,v in pairs(result[1]) do 
                    items[v.slot] = v 
                end
            end
        end
    end)
    return items 
end

GetFreeSlot = function(id)
    if Stashes[id] then
        for i=1,Stashes[id].slots do
            if Stashes[id].items[i] == nil then 
                return i 
            end
        end
    end
end

GetNumberFromString = function(string)
    return tonumber(string.match(string, "%d+"))
end

CanCarryItem = function(src,item,amount)
    local retval = false
	local inventory = QBCore.Functions.GetPlayer(src).PlayerData.items
	local weight = 0
	for k,v in pairs(inventory) do
		weight = weight + (v.weight*v.amount)
	end
	local itemweight = (QBCore.Shared.Items[item].weight)*amount
	if (weight+itemweight) <= QBCore.Config.Player.MaxWeight then
		retval = true
    end
    return retval
end