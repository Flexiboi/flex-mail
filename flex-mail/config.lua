Config = {}

Config.debug = true

Config.envelopitem = 'envelop'

Config.postofficeblip = {
    sprite = 267,
    color = 0,
    scale = 0.6 
}

Config.mailbox = {
    targetmodel = {
        targeticon = 'fa fa-envelope-o',
        label = 'Open brievenbus',
        models = {
            'v_corp_postbox',
            'v_corp_post_open',
            'v_corp_postboxa',
            'prop_postbox_01a',
            'prop_postbox_ss_01a'
        },
        distance = 1.5,
    },
    zones = {
        -- [1] = {
        --     targeticon = 'fa fa-envelope-o',
        --     label = 'Open mailbox',
        --     coords = vec3(0,0,0),
        --     box = {
        --         length = 2, -- Length of the zone
        --         depth = 2, -- Depth of the zone
        --         min = -1, -- Coords z - this value
        --         max = 1 -- Coords z + this value
        --     },
        --     heading = 0,
        --     distance = 1.5
        -- },
    }
}

Config.postofficeLocs = {
    vector3(-20.68, 6490.48, 31.5),
}