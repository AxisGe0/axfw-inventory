QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)


RegisterCommand('convert',function()
    QBCore.Functions.ExecuteSql(false,"SELECT * FROM `stashitemsnew`",function(result)
        for k,v in pairs(result) do 
            QBCore.Functions.ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('"..v.stash.."','"..v.items.."')  ")
        end
        print('Done Stash')
    end)
    QBCore.Functions.ExecuteSql(false,"SELECT * FROM `gloveboxitemsnew`",function(result)
        for k,v in pairs(result) do 
            QBCore.Functions.ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('GloveBox-"..v.plate:gsub(' ','').."','"..v.items.."')  ")
        end
        print('Done GloveBox')
    end)
    QBCore.Functions.ExecuteSql(false,"SELECT * FROM `trunkitemsnew`",function(result)
        for k,v in pairs(result) do 
            QBCore.Functions.ExecuteSql(true,"INSERT INTO `inventories` (`id`,`data`) VALUES ('Trunk-"..v.plate:gsub(' ','').."','"..v.items.."')  ")
        end
        print('Done Trunk')
    end)
end)