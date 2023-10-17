local Translations = {
    error = {
        noenvelop = 'You dont have an empty envelope..',
    },
    success = {
    },
    info = {
        blipname = 'Postoffice',
        deliverenvelop = 'Drag to use to send the letter!'
    },
    target = {
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
