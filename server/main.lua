local WebhookURL = ''

-- Get Player Inventory
lib.callback.register('marketplace:getItems', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventory = xPlayer.getInventory(true)
    local info = {}
    for k, v in pairs(inventory) do
        local check = blacklist(v.name)
        if not check then
            table.insert(info, {
                item = v.name, 
                label = ESX.GetItemLabel(v.name),
                amount = v.count,
            })            
        end        
    end
    return info
end)

-- check if item is blacklisted
function blacklist(item)
    for k, v in pairs(Config.Blacklist) do
        if item == v then
            return true
        end
    end
end

-- get own offers
lib.callback.register('marketplace:getOwn', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = MySQL.query.await('SELECT * FROM marketplace WHERE identifier = ?', {xPlayer.identifier})
    local inserts = {}
    for k, v in pairs(data) do
        table.insert(inserts, {
            id = v.id,
            label = v.label,
            amount = v.amount,
            price = v.price,
            item = v.item
        })
    end
    return inserts
end)

-- get all offers
lib.callback.register('marketplace:getAll', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = MySQL.query.await('SELECT * FROM marketplace', {})
    local inserts = {}
    for k, v in pairs(data) do
        if v.identifier ~= xPlayer.identifier then
            local check = isPlayerOnline(v.identifier)
            if check then
                table.insert(inserts, {
                    id = v.id,
                    item = v.item,
                    amount = v.amount,
                    price = v.price,
                    label = v.label,
                })
            end   
        end
    end
    return inserts
end)

-- check if is seller online
function isPlayerOnline(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        return true
    else
        return false
    end
end

-- has player item
lib.callback.register('marketplace:hasItem', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local count = xPlayer.getInventoryItem(item).count

    if count >= 1 then
        return count
    else
        return false
    end
end)

RegisterServerEvent('marketplace:insert')
AddEventHandler('marketplace:insert', function(item, amount, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getInventoryItem(item).count >= amount then
        xPlayer.removeInventoryItem(item, amount)
        MySQL.insert('INSERT INTO marketplace (identifier, item, label, amount, price) VALUES (?, ?, ?, ?, ?)', {
            xPlayer.identifier, item, ESX.GetItemLabel(item), amount, price
        })
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['insert_done'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'info'})
        if not Config.EnableWebhook then
            return
        end
        exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['new_insert'], Config.Text['new_insert_desc']..'\n**Item:** '..amount..'x '..ESX.GetItemLabel(item)..'\n**PRICE:** '..price..'$', xPlayer.source)
    else
        print('no item')
    end
end)

RegisterServerEvent('marketplace:buy')
AddEventHandler('marketplace:buy', function(id, item, amount, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    local check = MySQL.query.await('SELECT * FROM marketplace WHERE id = ?', {id})

    if check then 
        for k, v in pairs(check) do
            local seller = ESX.GetPlayerFromIdentifier(v.identifier)
            if seller then
                if v.amount >= amount then 
                    if xPlayer.getMoney() >= amount * price then 
                        if xPlayer.canCarryItem(item, amount) then 
                            xPlayer.removeMoney(amount * price)
                            xPlayer.addInventoryItem(item, amount)

                            seller.addMoney(amount * price)
                            TriggerClientEvent('ox_lib:notify', seller.source, {description = Config.Text['item_selled'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'info'})            
    
                            if v.amount - amount == 0 then 
                                MySQL.query('DELETE FROM marketplace WHERE id = ?', { id })
                            else
                                MySQL.update('UPDATE marketplace SET amount = ? WHERE id = ?', {
                                    v.amount - amount, v.id
                                })
                            end

                            if not Config.EnableWebhook then
                                return
                            end
                            exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['sold_wb'], Config.Text['sold_wb_desc']..'\n**ITEM:** '..amount..'x '..ESX.GetItemLabel(item)..'\n**PRICE:** '..amount * price..'\n**ID:** '..id, xPlayer.source)                    
                        else
                            TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_space'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
                        end
                    else
                        TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_money'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
                    end
                else
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['not_enough'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
                end
            else
                TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['seller_not_online'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
            end
        end    
    else
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_offer'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
    end
end)

RegisterServerEvent('marketplace:delete')
AddEventHandler('marketplace:delete', function(id, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.canCarryItem(item, amount) then
        MySQL.query('DELETE FROM marketplace WHERE id = ?', { id })
        xPlayer.addInventoryItem(item, amount)
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['deleted_success'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'success'})
        if not Config.EnableWebhook then
            return
        end
        exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['insert_deleted'], Config.Text['insert_deleted_desc']..'\n**ITEM:** '..amount..'x '..ESX.GetItemLabel(item)..'\n**ID:** '..id, xPlayer.source)
    else
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_space'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
    end
end)

RegisterServerEvent('marketplace:updatePrice')
AddEventHandler('marketplace:updatePrice', function(id, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.update('UPDATE marketplace SET price = ? WHERE id = ?', {
        price, id
    })
    TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['edit_success'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'success'})
    if not Config.EnableWebhook then
        return
    end
    exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['insert_price'], Config.Text['insert_price_desc']..'\n**ID:** '..id..'\n**PRICE:** '..price, xPlayer.source)
end)

RegisterServerEvent('marketplace:updateAmount')
AddEventHandler('marketplace:updateAmount', function(option, id, item, old, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if option == 'remove' then
        if xPlayer.canCarryItem(item, amount) then
            MySQL.update('UPDATE marketplace SET amount = ? WHERE id = ?', {
               old - amount, id
            })
            xPlayer.addInventoryItem(item, amount)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['edit_success'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'success'})
            if not Config.EnableWebhook then
                return
            end
            exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['insert_amount'], Config.Text['insert_amount_desc']..'\n**ID:** '..id..'\n**OLD:** '..old..'\n**NEW:** '..old - amount, xPlayer.source)
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_space'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
        end    
    else
        if xPlayer.getInventoryItem(item).count >= amount then
            MySQL.update('UPDATE marketplace SET amount = ? WHERE id = ?', {
               amount + old, id
            })
            xPlayer.removeInventoryItem(item, amount)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['edit_success'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'success'})
            if not Config.EnableWebhook then
                return
            end
            exports['DFNZ_LOGGER']:sendHook(WebhookURL, Config.Text['insert_amount'], Config.Text['insert_amount_desc']..'\n**ID:** '..id..'\n**OLD:** '..old..'\n**NEW:** '..old + amount, xPlayer.source)
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {description = Config.Text['no_item'], position = Config.Notify.position, duration = Config.Notify.duration * 1000, iconAnimation = Config.Notify.animation, type = 'error'})
        end    
    end
end)

-- admin command
lib.addCommand(Config.AdminCommand, {
    help = Config.Text['admin_help'],
    params = {
        {
            name = 'id',
            type = 'number',
            help = Config.Text['admin_help_info'],
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.id then
        return
    end
    MySQL.query('DELETE FROM marketplace WHERE id = ?', { args.id })
    if not Config.EnableWebhook then
        return
    end
end)

-- script startup
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if not Config.EnableWebhook then
        print('^1[INFO]^0 Webhhoks are disabled!')
    else
        print('^2[INFO]^0 Webhhoks are enabled!')
    end
end)