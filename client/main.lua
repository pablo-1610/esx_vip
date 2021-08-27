ESX, vipLevel, isMenuActive = nil, 0, false

function getBaseSkin()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0
        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
                TriggerEvent('esx:restoreLoadout')
            end)
        end)

    end)
end

Citizen.CreateThread(function()
    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
    end)
    TriggerServerEvent("zVip:requestVipLevel")
end)

RegisterNetEvent("zVip:callbackVipLevel")
AddEventHandler("zVip:callbackVipLevel", function(incomingVipLevel)
    if incomingVipLevel > 0 then ESX.ShowNotification("Vous avez un niveau de vip de: ~o~"..incomingVipLevel) end
    vipLevel = incomingVipLevel
end)

RegisterCommand("vip", function(source)
    if vipLevel <= 0 then
        ESX.ShowNotification("~r~Vous n'avez pas la permission d'executer cette commande, veuillez visiter notre boutique")
        return
    end
    isMenuActive = true
    RMenu.Add("vip", "vip_menu", RageUI.CreateMenu("Menu VIP", "~b~Utilisez vos avantages"))
    RMenu:Get("vip", "vip_menu").Closed = function()
    end

    RMenu.Add("vip", "vip_peds", RageUI.CreateSubMenu(RMenu:Get("vip", "vip_menu"), "Apparences peds", "~b~Changez vous en ped"))
    RMenu:Get("vip", "vip_peds").Closed = function()
    end

    RageUI.Visible(RMenu:Get("vip", "vip_menu"), true)
    Citizen.CreateThread(function()
        while isMenuActive do
            local shouldStayOpened = false
            local function tick()
                shouldStayOpened = true
            end

            RageUI.IsVisible(RMenu:Get("vip", "vip_menu"), true, true, true, function()
                
                RageUI.ButtonWithStyle("Apparences peds", "Vous permets de vous métamortphoser en ped", {}, true, function(_,_,s)
                end, RMenu:Get("vip", "vip_peds"))

                tick()
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get("vip", "vip_peds"), true, true, true, function()
                RageUI.ButtonWithStyle("Reprendre mon apparence", "Vous permets de reprendre votre apparence de base", {}, true, function(_,_,s)
                    if s then
                        getBaseSkin()
                    end
                end)
                RageUI.Separator("~o~Peds disponibles")
                for k,v in pairs(Config.availablePeds) do
                    RageUI.ButtonWithStyle("\"~y~"..v[1].."~s~\"", "Appuyez sur ~g~entrer~s~ pour prendre l'apparence de ce ped.", {}, true, function(_,_,s)
                        if s then
                            local model = GetHashKey(v[2])
                            RequestModel(model)
                            while not HasModelLoaded(model) do Wait(1) end
                            SetPlayerModel(PlayerId(), model)
                            SetModelAsNoLongerNeeded(model)
                        end
                    end)
                end
                tick()
            end, function()
            end)


            if not shouldStayOpened and isMenuActive then
                isMenuActive = false
            end
            Wait(0)
        end
    end)
end, false)