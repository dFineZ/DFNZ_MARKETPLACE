Config = {}

-- If you need help or have any suggestions join my discord server https://discord.gg/B9dKDwD4Au

Config.EnableWebhook = true  --> if true you need to have DFNZ_LOGGER installed (also set Config.UseLogger to true) or implement your own system
                             --> if you want to use your own webhook system go to fxmanifest.lua and remove DFNZ_LOGGER dependencies
                             --> set your webhook link in server/main.lua line 1

Config.Command = { 
    enable = false, --> set this to true if you want to use a command for open the marketplace
    command = 'marketplace'
}

Config.AdminCommand = 'admin_market' --> use this to delete an advertisment EXAMPEL: /admin_market 1 (delets the advertisment with id 1)

Config.Key = { 
    enable = false, --> set this to true if you want to use a hotkey for open the marketplace
    key = 'F6'
}

Config.Notify = {
    position = 'top',
    duration = 4,                   --> in seconds
    animation = 'beatFade'
}

Config.Items = {
    blacklist = true,  --> if you set this to true all items in the items table can not be sold / if false only the items in the items table can be sold
    items = {'money', 'black_money', 'WEAPON_PISTOL'} --> add as many items you want
}

Config.Account = 'money' --> choose between money/bank or black_money (IMPORTANT the seller gets the money in the same account)

Config.Location = { --> edit this if you want to use a static location for your marketplace
    enable = true, --> set this to false if you dont want to use a static location
    coords = vec4(-1122.2610, -1647.7655, 4.3546, 124.4954),
    useTarget = true,   --> if you dont use ox_target then go to fxmanifest.lua and remove ox_target dependencies
    textui = {
        enable = false,  --> set this to true if you set useTarget = false
        key = 'E',
        icon = 'circle-info',
        animation = 'beatFade',
        color = '#fffff',
        position = 'right-center',
    },
    blip = {    --> only works if Config.Location.enable = true
        enable = true,
        sprite = 374,
        size = 0.8,
        color = 2,
        name = 'Marketplace'
    },
    ped = {
        enable = true,
        ped = 'a_f_m_bevhills_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD_FACILITY'
    },
    marker = {
        enable = false,
        type = 29,
        size = {1.0, 1.0, 1.0},
        color = {255, 255, 255, 100}
    }
}

Config.Text = { -- EN 
    -- INGAME
    ['target'] = 'Open marketplace',
    ['textui'] = '['..Config.Location.textui.key..'] Open marketplace',
    ['menu'] = 'Marketplace',
    ['create_new'] = 'Insert item',
    ['create_new_desc'] = 'Insert item to the marketplace',
    ['edit_own'] = 'Edit advertisments',
    ['edit_own_desc'] = 'Edit your own advertisments',
    ['show_inserts'] = 'Show advertisments',
    ['show_inserts_desc'] = 'Show all advertisments from the marketplace',
    ['insert_done'] = 'Your advertisment is now live',
    ['no_item'] = 'You dont have the right item',
    ['item_selled'] = 'One of your advertisment is selled',
    ['no_space'] = 'You have enough space in your pocket',
    ['no_money'] = 'You dont have enough money',
    ['not_enough'] = 'There are not enough units from this offer',
    ['no_offer'] = 'The advertisment is not avalible anymore', 
    ['admin_help'] = 'Delete a advertisment from the marketplace',
    ['admin_help_info'] = 'Enter the advertisment id',
    ['advertisment'] = 'Advertisment ',
    ['hover_for_info'] = 'Hover for more informations',
    ['price_per_unit'] = 'Price per unit',
    ['avaliable_units'] = 'Avaliable units',
    ['how_much_sell'] = 'How many do you want to sell?',
    ['complete_buy'] = 'Complete purchase',
    ['want_buy'] = 'Do you want to buy this offer: ',
    ['yes'] = 'Yes!',
    ['no'] = 'No',
    ['edit_desc'] = 'Click to edit this advertisment',
    ['delete'] = 'Delete',
    ['delete_desc'] = 'Delete this advertisment',
    ['delete_ask'] = 'Are you sure you want to delete this advertisment?',
    ['edit_price'] = 'Edit price',
    ['edit_price_desc'] = 'Edit the price per unit',
    ['current_price'] = 'Current price: ',
    ['edit_amount'] = 'Edit amount',
    ['edit_amount_desc'] = 'Edit the avaliable units of this advertisment',
    ['current_amount'] = 'Current amount: ',
    ['edit_success'] = 'Your advertisment has successfully changed',
    ['delete_success'] = 'Your advertisment has been deleted',
    ['seller_not_online'] = 'The seller is not avaliable right now. Please try again later',
    ['add_units'] = 'Add more units',
    ['add_many'] = 'How much do you want to add?',
    ['add_units_desc'] = 'Add more units of this item',
    ['remove_units'] = 'Remove some units',
    ['remove_many'] = 'How many do you want wo remove?',
    ['remove_units_desc'] = 'Remove some units from this advertisment',
    -- WEBHOOKS
    ['new_insert'] = 'New advertisment',
    ['new_insert_desc'] = 'A new advertisment has been added, here are some infos',
    ['insert_deleted'] = 'Advertisment deleted', 
    ['insert_deleted_desc'] = 'A advertisment has been deleted, here are some infos',
    ['insert_price'] = 'Advertisment price change',
    ['insert_price_desc'] = 'A advertisment has changed his price, here are some infos',
    ['insert_amount'] = 'Advertismnet amount change', 
    ['insert_amount_desc'] = 'A advertisment has changed his amount, here are some infos',
    ['sold_wb'] = 'Items bought',
    ['sold_wb_desc'] = 'Some items from an advertisment are bought, here are some infos'
}

-- Config.Text = { -- DE 
--     -- INGAME
--     ['target'] = 'Marktplatz öffnen',
--     ['textui'] = '['..Config.Location.textui.key..'] Marktplatz öffnen',
--     ['menu'] = 'Marktplatz',
--     ['create_new'] = 'Gegenstand anbieten',
--     ['create_new_desc'] = 'Biete einen Gegenstand auf dem Marktplatz an',
--     ['edit_own'] = 'Angebote bearbeiten',
--     ['edit_own_desc'] = 'Bearbeite deine eigenen Angebote',
--     ['show_inserts'] = 'Angebote ansehen',
--     ['show_inserts_desc'] = 'Sieh dir alle verfügbaren Angebote an',
--     ['insert_done'] = 'Dein Angebot ist nun online',
--     ['no_item'] = 'Du hast nicht den richtigen Gegenstand',
--     ['item_selled'] = 'Eins deiner Angebote wurde gekauft',
--     ['no_space'] = 'Du hast nicht genug Platz in deinen Taschen',
--     ['no_money'] = 'Du hast nicht genug Bargeld',
--     ['not_enough'] = 'Du willst mehr kaufen als verfügbar ist',
--     ['no_offer'] = 'Das Angebot ist nicht mehr verfügbar', 
--     ['admin_help'] = 'Lösche ein Angebot vom Marktplatz',
--     ['admin_help_info'] = 'Angebots ID',
--     ['advertisment'] = 'Angebot ',
--     ['hover_for_info'] = 'Fahre hier rüber für mehr Infos',
--     ['price_per_unit'] = 'Preis pro Stück',
--     ['avaliable_units'] = 'Verfügbare Anzahl',
--     ['how_much_sell'] = 'Wie wiel möchtest du verkaufen?',
--     ['complete_buy'] = 'Kauf abschließen',
--     ['want_buy'] = 'Möchtest du dieses Angebot annehmen: ',
--     ['yes'] = 'Ja',
--     ['no'] = 'Nein',
--     ['edit_desc'] = 'Klicke hier um das Angebot zu berarbeiten',
--     ['delete'] = 'Löschen',
--     ['delete_desc'] = 'Lösche dieses Angebot',
--     ['delete_ask'] = 'Bist du sicher das du das Angebot löschen möchtest?',
--     ['edit_price'] = 'Preis bearbeiten',
--     ['edit_price_desc'] = 'Bearbeite den Stückpreis für dieses Angebot',
--     ['current_price'] = 'Aktueller Preis: ',
--     ['edit_amount'] = 'Stückzahl bearbeiten',
--     ['edit_amount_desc'] = 'Bearbeite die verfügbare Stückzahl für dieses Angebot',
--     ['current_amount'] = 'Aktuelle Stückzahl: ',
--     ['edit_success'] = 'Dein Angebot wurde erfolgreich bearbeitet',
--     ['delete_success'] = 'Dein Angebot wurde gelöscht',
--     ['seller_not_online'] = 'Der Verkäufer ist gerade nicht verfügbar, bitte versuche es später noch einmal.',
--     ['add_units'] = 'Erhöhen',
--     ['add_many'] = 'Wie viel möchest du hinzufügen?',
--     ['add_units_desc'] = 'Erhöhe die Stückzahl des Artikels',
--     ['remove_units'] = 'Verringern',
--     ['remove_many'] = 'Wie viel möchtest du entfernen?',
--     ['remove_units_desc'] = 'Verringere die Stückzahl des Artikels',
--     -- WEBHOOKS
--     ['new_insert'] = 'Neues Angebot',
--     ['new_insert_desc'] = 'Ein neues Angebot wurde erstellt. Hier sind ein paar Infos',
--     ['insert_deleted'] = 'Angebot gelöscht', 
--     ['insert_deleted_desc'] = 'Ein Angebot wurde gelöscht. Hier sind ein paar Infos',
--     ['insert_price'] = 'Preisänderung',
--     ['insert_price_desc'] = 'Der Angebotspreis hat sich geändert. Hier sind ein paar Infos',
--     ['insert_amount'] = 'Artikelstückzahl', 
--     ['insert_amount_desc'] = 'Die Artikelstückzahl hat sich geänder. Hier sind ein paar Infos',
--     ['sold_wb'] = 'Gegenstände gekauft',
--     ['sold_wb_desc'] = 'Es wurden Gegenstände gekauft. Hier sind ein paar Infos'
-- }
