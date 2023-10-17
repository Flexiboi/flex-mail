local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem(Config.envelopitem , function(source, item)
    if item.info.mailid then
        TriggerClientEvent('flex-mail:client:useEnvelop', source, item.info.mailid)
    else
        TriggerClientEvent('flex-mail:client:useEnvelop', source)
    end
end)

QBCore.Functions.CreateCallback('flex-mail:server:getAllMails', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local maillist = {}
    local mails = MySQL.query.await('SELECT * FROM player_postmails WHERE cid = ?', { Player.PlayerData.citizenid })
    if mails[1] ~= nil then
        for k, v in pairs(mails) do
            maillist[k] = {
                mailid = v.mailid,
                sender = v.sender,
                receiver = v.receiver,
                subject = v.subject,
                mail = v.mail,
            }
        end
    end
    cb(maillist)
end)

QBCore.Functions.CreateCallback('flex-mail:server:getMail', function(source, cb, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local email = {}
    local mail = MySQL.query.await('SELECT * FROM player_postmails WHERE mailid = ?', { id })
    if mail[1] ~= nil then
        email = {
            mailid = mail[1].mailid,
            sender = mail[1].sender,
            receiver = mail[1].receiver,
            subject = mail[1].subject,
            mail = mail[1].mail,
        }
    end
    cb(email)
end)

QBCore.Functions.CreateCallback('flex-mail:server:readMail', function(source, cb, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local email = {}
    local mail = MySQL.query.await('SELECT * FROM player_mailconcept WHERE mailid = ?', { id })
    if mail[1] ~= nil then
        email = {
            mailid = mail[1].mailid,
            sender = mail[1].sender,
            receiver = mail[1].receiver,
            subject = mail[1].subject,
            mail = mail[1].mail,
        }
    end
    cb(email)
end)

RegisterNetEvent('flex-mail:server:removemail', function(id)
    MySQL.query('DELETE FROM player_postmails WHERE mailid = ?', {id})
end)

RegisterNetEvent('flex-mail:server:write', function(email, subject, mailtext)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByEmail(email)
    if Player ~= nil and Target ~= nil then
        local item = Player.Functions.GetItemByName(Config.envelopitem)
        if item and item.amount >= 1 then
            if not item.info.mailid then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.envelopitem], "remove", 1)
                Player.Functions.RemoveItem(Config.envelopitem, 1)
            else
                return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.noenvelop'), 'error')
            end
        else
            return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.noenvelop'), 'error')
        end
        local mid = GenerateMailId('player_mailconcept')
        MySQL.insert('INSERT INTO player_mailconcept (mailid, cid, sender, receiver, subject, mail) VALUES (?, ?, ?, ?, ?, ?)', {
            mid,
            Player.PlayerData.citizenid,
            Player.PlayerData.metadata.email,
            email,
            subject,
            mailtext
        })
        local info = {}
        info.mailid = mid
        if Player.Functions.AddItem(Config.envelopitem, 1, false, info) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.envelopitem], 'add', 1)
        end
    end
end)

RegisterNetEvent('flex-mail:server:send', function(id)
    local src = source
    local mail = MySQL.query.await('SELECT * FROM player_mailconcept WHERE mailid = ?', { id })
    if mail[1] ~= nil then
        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayerByEmail(mail[1].receiver)
        if Player ~= nil and Target ~= nil then
            local item = Player.Functions.GetItemByName(Config.envelopitem)
            if item and item.amount >= 1 then
                if item.info.mailid == id then
                    if Player.Functions.RemoveItem(Config.envelopitem, 1) then
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.envelopitem], "remove", 1)
                        local mid = GenerateMailId('player_postmails')
                        MySQL.insert('INSERT INTO player_postmails (mailid, cid, sender, receiver, subject, mail) VALUES (?, ?, ?, ?, ?, ?)', {
                            mid,
                            Target.PlayerData.citizenid,
                            Player.PlayerData.metadata.email,
                            Target.PlayerData.metadata.email,
                            mail[1].subject,
                            mail[1].mail
                        })
                        MySQL.query('DELETE FROM player_mailconcept WHERE mailid = ?', {id})
                    end
                end
            end
        end
    end
end)

function GenerateMailId(table)
    local UniqueFound = false
    local mailid = nil
    while not UniqueFound do
        mailid = math.random(0, 999999999)
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM ' .. table .. ' WHERE mailid LIKE ?', { mailid })
        if result == 0 then
            UniqueFound = true
        end
    end
    return mailid
end