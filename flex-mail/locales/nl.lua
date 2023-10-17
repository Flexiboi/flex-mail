local Translations = {
    error = {
        noenvelop = 'Je hebt geen lege envelop bij..',
    },
    success = {
    },
    info = {
        blipname = 'Postkantoor',
        deliverenvelop = 'Sleep naar gebruik om je brief te versturen!'
    },
    target = {
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
