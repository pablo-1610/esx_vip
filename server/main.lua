ESX, vips = nil, {}

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

Citizen.CreateThread(function()
    MySQL.Async.fetchAll("SELECT identifier, viplevel FROM users WHERE viplevel > 0", {}, function(result)
        for id, data in pairs(result) do
            vips[data.identifier] = data.viplevel
        end
    end)
end)

-- Communication avec le joueur
RegisterNetEvent("zVip:requestVipLevel")
AddEventHandler("zVip:requestVipLevel", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local identifier = xPlayer.identifier
    print("Send back vip level")
    TriggerClientEvent("zVip:callbackVipLevel", _src, (vips[identifier] or 0))
end)
    
-- Commande RCON
RegisterCommand("setvip", function(source, args)
    if source ~= 0 then return end
    if #args ~= 1 then return end
    local target = args[1]
    if tonumber(target) == nil then
        print("ID invalide")
        return
    end  
    local xPlayer = ESX.GetPlayerFromId(tonumber(target))
    local targetIdentifier = xPlayer.identifier
    TriggerClientEvent("zVip:callbackVipLevel", tonumber(target), 1)
    MySQL.Async.execute("UPDATE users SET viplevel = 1 WHERE identifier = @a", {['a'] = targetIdentifier})
    print("Le joueur est désormais VIP !")
end, false)