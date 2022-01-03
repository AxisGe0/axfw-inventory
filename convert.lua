ExecuteSql = function(ignr,query,cb)
    local data = exports.oxmysql:fetchSync(query)
    if cb ~= nil then
        cb(data)
    end
    return data
end
RegisterCommand('convert',function()
    ExecuteSql(false,"SELECT * FROM `stashitems`",function(result)
        for k,v in pairs(result) do 
            ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('"..v.stash.."','"..v.items.."')  ")
        end
        print('Done Stash')
    end)
    ExecuteSql(false,"SELECT * FROM `gloveboxitems`",function(result)
        for k,v in pairs(result) do 
            ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('GloveBox-"..v.plate:gsub(' ','').."','"..v.items.."')  ")
        end
        print('Done GloveBox')
    end)
    ExecuteSql(false,"SELECT * FROM `trunkitems`",function(result)
        for k,v in pairs(result) do 
            ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('Trunk-"..v.plate:gsub(' ','').."','"..v.items.."')  ")
        end
        print('Done Trunk')
    end)
end)
