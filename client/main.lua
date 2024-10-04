local market = Config.Location
local hasUi = false
local ped

-- Command thread
CreateThread(function()
    if not Config.Command.enable then return end

    RegisterCommand(Config.Command.command, function()
        openMain()
    end)
end)

-- Key thread
CreateThread(function()
    if not Config.Key.enable then return end

    local keybind = lib.addKeybind({
        name = 'open_marketplace',
        description = 'Press to open the marketplace',
        defaultKey = Config.Key.key,
        onReleased = function(self)
            openMain()
        end
    })
end)

-- Blip thread
CreateThread(function()
    if not market.blip.enable or not market.enable then return end

    local blip = AddBlipForCoord(market.coords[1], market.coords[2], market.coords[3])
    SetBlipDisplay(blip, 4)
    SetBlipSprite(blip, market.blip.sprite)
    SetBlipColour(blip, market.blip.color)
    SetBlipScale(blip, market.blip.size)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(market.blip.name)
    EndTextCommandSetBlipName(blip)
end)

-- Point thread
CreateThread(function()
    if not market.enable then return end

    local point = lib.points.new({
        coords = vec3(market.coords[1], market.coords[2], market.coords[3]),
        distance = 20,
    })
    
    if market.ped.enable then
        function point:onEnter()
            spawnPed()
        end
    
        function point:onExit()            
            deletePed()
        end
        market.marker.enable = false
    else
        market.useTarget = false
        marker.textui.enable = false
        market.marker.enable = true
    end
    
    if market.marker.enable or not market.useTarget then
        local marker = lib.marker.new({
            type = market.marker.type,
            coords = vec3(market.coords.x, market.coords.y, market.coords.z), 
            width = market.marker.size[1],
            height = market.marker.size[2],
            color = { r = market.marker.color[1], g = market.marker.color[2], b = market.marker.color[3], a = market.marker.color[4] },
        })

        function point:nearby()
            if self.currentDistance < 8.0 and market.marker.enable then
                marker:draw()
            end
    
            if self.currentDistance < 2.0 and not market.useTarget then
                if not hasUi then
                    lib.showTextUI(Config.Text['textui'], {position = market.textui.position, icon = market.textui.icon, iconAnimation = market.textui.animation, iconColor = market.textui.color})
                    hasUi = true
                end
            end
    
            if self.currentDistance > 2.0 and hasUi then
                lib.hideTextUI()
                hasUi = false
            end
        end
    end
    
end)

-- Key thread
CreateThread(function()
    if market.useTarget then return end

    local textui = lib.addKeybind({
        name = 'open_marketplace_ui',
        description = 'Press to open the marketplace',
        defaultKey = market.textui.key,
        onReleased = function(self)
            if not hasUi then return end
            openMain()
        end
    })
end)

-- main menu
function openMain()
    lib.registerContext({
        id = 'marketplace',
        title = Config.Text['menu'],
        options = {
            {
                title = Config.Text['create_new'],
                description = Config.Text['create_new_desc'],
                icon = 'plus',
                arrow = true,
                onSelect = function()
                    insertNew()
                end
            },
            {
                title = Config.Text['edit_own'],
                description = Config.Text['edit_own_desc'],
                icon = 'pen-to-square',
                arrow = true,
                onSelect = function()
                    editOwn()
                end
            },
            {
                title = Config.Text['show_inserts'],
                description = Config.Text['show_inserts_desc'],
                icon = 'basket-shopping',
                arrow = true,
                onSelect = function()
                    showInserts()
                end
            },
        }
    })
    lib.showContext('marketplace')
end

-- insert new 
function insertNew()
    local data = {}
    lib.callback('marketplace:getItems', false, function(items)
        for k, v in pairs(items) do 
            table.insert(data, {
                title = v.label, 
                description = Config.Text['avaliable_units']..': '..v.amount..'x',
                icon = 'plus', 
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog(v.label, {
                        {type = 'slider', min = 1, max = v.amount, label = Config.Text['how_much_sell'], required = true},
                        {type = 'number', min = 1, label = Config.Text['price_per_unit'], required = true}
                    })
                    if input == nil then 
                        insertNew()
                        return
                    end

                    TriggerServerEvent('marketplace:insert', v.item, input[1], input[2])
                    openMain()
                end
            })
        end
        lib.registerContext({id = 'marketplace_new', title = Config.Text['create_new'], menu = 'marketplace', options = data})
        lib.showContext('marketplace_new')
    end)
end

-- edit own offers
function editOwn()
    local data = {}
    lib.callback('marketplace:getOwn', false, function(items)
        for k, v in pairs(items) do 
            table.insert(data, {
                title = Config.Text['advertisment']..v.id..': '..v.label, 
                description = Config.Text['edit_desc'],
                icon = 'hashtag', 
                arrow = true,
                metadata = {
                    {value = v.price..'$', label = Config.Text['price_per_unit']},
                    {value = v.amount..'x', label = Config.Text['avaliable_units']}
                },
                onSelect = function()
                    lib.registerContext({
                        id = 'marketplace_edit',
                        title = Config.Text['advertisment']..v.id..': '..v.label,
                        menu = 'marketplace_own',
                        options = {
                            {
                                title = Config.Text['delete'], 
                                description = Config.Text['delete_desc'],
                                arrow = true,
                                icon = 'trash',
                                onSelect = function()
                                    local alert = lib.alertDialog({
                                        header = Config.Text['delete'],
                                        content = Config.Text['delete_ask'],
                                        cancel = true,
                                        centered = true,
                                        labels = {
                                            confirm = Config.Text['yes'],
                                            cancel = Config.Text['no']
                                        }
                                    })
                                    if alert == 'confirm' then
                                        TriggerServerEvent('marketplace:delete', v.id, v.item, v.amount)
                                        Wait(500) --> dont delete this! sometimes players can delete the same advertisment again if there is no wait.. so they can exploid the script!!
                                        editOwn()
                                    else 
                                        editOwn()
                                    end
                                end
                            },
                            {
                                title = Config.Text['edit_price'], 
                                description = Config.Text['edit_price_desc'],
                                arrow = true,
                                icon = 'pen-to-square',
                                onSelect = function()
                                    local input = lib.inputDialog(Config.Text['edit_price'], {
                                        {type = 'number', min = 1, required = true, title = Config.Text['current_price']..v.price}
                                    })
                                    if input == nil then
                                        editOwn()
                                    else
                                        TriggerServerEvent('marketplace:updatePrice', v.id, input[1])
                                        Wait(500) --> dont delete this! sometimes players can delete the same advertisment again if there is no wait.. so they can exploid the script!!
                                        editOwn()
                                    end
                                end
                            },
                            {
                                title = Config.Text['edit_amount'], 
                                description = Config.Text['edit_amount_desc'],
                                arrow = true,
                                icon = 'pen-to-square',
                                onSelect = function()
                                    lib.registerContext({
                                        id = 'marketplace_edit_amount',
                                        title = Config.Text['edit_amount'],
                                        menu = 'marketplace_edit',
                                        options = {
                                            {
                                                title = Config.Text['add_units'],
                                                description = Config.Text['add_units_desc'],
                                                icon = 'plus',
                                                arrow = true,
                                                onSelect = function()
                                                    lib.callback('marketplace:hasItem', false, function(result)
                                                        if not result then
                                                            lib.notify({description = Config.Text['no_item'], duration = Config.Notify.duration * 1000, position = Config.Notify.position, type = 'error', iconAnimation = Config.Notify.animation})
                                                        else
                                                            input = lib.inputDialog(Config.Text['edit_amount'], {
                                                                {type = 'slider', min = 1, default = v.amount, max = result, required = true, label = Config.Text['add_many']}
                                                            })
                                                            if input == nil then
                                                                editOwn()
                                                            else
                                                                TriggerServerEvent('marketplace:updateAmount', 'add', v.id, v.item, v.amount, input[1])
                                                                Wait(500) --> dont delete this! sometimes players can delete the same advertisment again if there is no wait.. so they can exploid the script!!
                                                                editOwn()
                                                            end
                                                        end
                                                    end, v.item)
                                                end
                                            },
                                            {
                                                title = Config.Text['remove_units'],
                                                description = Config.Text['remove_units_desc'],
                                                icon = 'minus',
                                                arrow = true,
                                                onSelect = function()
                                                    input = lib.inputDialog(Config.Text['edit_amount'], {
                                                        {type = 'slider', min = 1, max = v.amount - 1, required = true, label = Config.Text['remove_many']}
                                                    })
                                                    if input == nil then
                                                        editOwn()
                                                    else
                                                        TriggerServerEvent('marketplace:updateAmount', 'remove', v.id, v.item, v.amount, input[1])
                                                        Wait(500) --> dont delete this! sometimes players can delete the same advertisment again if there is no wait.. so they can exploid the script!!
                                                        editOwn()
                                                    end
                                                end
                                            },

                                        }
                                    })
                                    lib.showContext('marketplace_edit_amount')
                                end
                            },
                        }
                    })
                    lib.showContext('marketplace_edit')
                end
            })
        end
        lib.registerContext({id = 'marketplace_own', title = Config.Text['edit_own'], menu = 'marketplace', options = data})
        lib.showContext('marketplace_own')
    end)
end

-- show offers 
function showInserts()
    local data = {}
    lib.callback('marketplace:getAll', false, function(inserts)
        for k, v in pairs(inserts) do 
            table.insert(data, {
                title = Config.Text['advertisment']..v.id..': '..v.label, 
                description = Config.Text['hover_for_info'],
                icon = 'shopping-basket', 
                arrow = true,
                metadata = {
                    {value = v.price..'$', label = Config.Text['price_per_unit']},
                    {value = v.amount..'x', label = Config.Text['avaliable_units']}
                },
                onSelect = function()
                    local input = lib.inputDialog(v.label, {
                        {type = 'number', min = 1, max = v.amount, description = Config.Text['buy_amount'], required = true},
                    })
                    if input == nil then 
                        showInserts()
                    end

                    local alert = lib.alertDialog({
                        header = Config.Text['complete_buy'],
                        content = Config.Text['want_buy']..input[1]..'x '..v.label..' = '..math.floor(input[1] * v.price)..'$',
                        cancel = true,
                        centered = true,
                        labels = {
                            confirm = Config.Text['yes'],
                            cancel = Config.Text['no']
                        }
                    })
                    if alert == 'confirm' then 
                        TriggerServerEvent('marketplace:buy', v.id, v.item, input[1], v.price)
                    else 
                        showInserts()
                    end
                end
            })
        end
        lib.registerContext({id = 'marketplace_inserts', title = Config.Text['show_inserts'], menu = 'marketplace', options = data})
        lib.showContext('marketplace_inserts')
    end)
end

-- spawn ped
function spawnPed()
    -- request ped
    local hash = GetHashKey(market.ped.ped)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end            
    -- create ped
    ped = CreatePed(4, hash, market.coords[1], market.coords[2], market.coords[3] - 1.0, market.coords[4], false, true)
    SetEntityHeading(ped, market.coords[4])
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, market.ped.scenario, -1, true) --> todo
    SetModelAsNoLongerNeeded(hash, true)
    -- set target
    if market.useTarget then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'marketplace',
                label = Config.Text['target'],
                icon = 'fa-solid fa-location-dot',
                onSelect = function()
                    openMain()
                end
            }
        })
    end
end

-- delete ped
function deletePed()
    DeleteEntity(ped)
end
