Config = {}

Config.DebugCode = false
Config.Notify = 'ox' -- check SendNotify functions for available notifies or configure your own inside the functions

Config.AddToRadialMenu = true --if true will add to oxlib radial menu // or you can manually place them wherever you want them in your radial menu
Config.RadialMenu = 'qb'

Config.AllowSharing = true
Config.SharingDistance = 20.0 --must be float
Config.MaxBlips = 20 --per player

Config.AllowPinging = true --allows players to ping their blip (putting a small radius glow effect around it) (only visible to them)
Config.PingBlipTimer = 5 --how many seconds the player blip with "glow" until returning back to normal
Config.BlipPingSprite = 161 --flashing blip. change if wanted

Config.AllowSetGPS = true --allows players to set GPS waypoint on the blip from menu
Config.AllowFastTravel = false --alot of people wont want this but its there for those that do

Config.BlipItem = false --false or itemcode to make the blip creator as an item
Config.BlipCreationRequiresThisItem = 'gps_beacon' --either false for no item needed to make blip or itemcode that is required

Config.BlipCommand = false --false or command code to make blip creator as a /command

Config.BlipDiscoveryRange = 30.0
Config.ShowDiscoveryUI = {
    Blip = true,
    Zone = true,
}

-- link to find Sprites/colours : https://docs.fivem.net/docs/game-references/blips/
Config.Sprites = { --sprite name followed by the number code of sprite (will only show these sprites as available)
    ['Race Flag'] = 38,
    ['House'] = 40,
    ['Helicopter'] = 43,
    ['Speech Bubble'] = 47,
    ['Drug Pill'] = 51,
    ['Basket'] = 52,
    ['Police Car'] = 56,
    ['Circle With Star'] = 58,
    ['Police Badge'] = 60,
    ['Hospital Badge'] = 61,
    ['Question Mark'] = 66,
    ['Security Van'] = 67,
    ['Tow Hook'] = 68,
    ['Spray Can'] = 72,
    ['Clothes'] = 73,
    ['Tattoo'] = 75,
    ['Letter A'] = 76, 
    ['Letter L'] = 77,
    ['Letter M'] = 78,
    ['Letter T'] = 79,
    ['Letter H'] = 80,
    ['Skull 1'] = 84,
    ['Tour Bus'] = 85,
    ['Letter F'] = 86,
    ['Letter C'] = 89,
    ['Airplane'] = 90,
    ['Cocktail Glass'] = 93,
    ['Parachute'] = 94,
    ['Car Wash'] = 100,
    ['Comedy'] = 102,
    ['Dartboard'] = 103,
    ['Dollar Sign'] = 108,
    ['Golf'] = 109,
    ['Pistol'] = 110,
    ['Letter X'] = 112,
    ['Crosshair'] = 119,
    ['High Heel'] = 121,
    ['Tennis'] = 122,
    -- [''] = 0,
    -- [''] = 0,
    -- [''] = 0,
}

Config.Colours = { --list of available blip colours
    ['Red'] = 1,
    ['Green'] = 2,
    ['Blue'] = 3,
    ['White'] = 4,
    ['Yellow'] = 5,
    ['Light Red'] = 6,
    ['Violet'] = 7,
    ['Pink'] = 8,
    ['Light Orange'] = 9,
    -- [''] = 0,
}

Config.Scales = { --list of available sizes you want players to use
    ['Small'] = 0.5,
    ['Regular'] = 1.0,
    ['Large'] = 1.5,
}

Config.DefaultBlips = {

    -- EXAMPLE. these blips will show for everyone. can be empty if you dont want any default blips (do not need to be discovered)
    -- [1] = {
    --     JobLocked = false, -- false or name of job 'police'
    --     vector = vector3(-499.42, 5268.11, 80.61),
    --     text = "Woodworking",
    --     color = 64,
    --     sprite = 566,
    --     scale = 0.5,
    --     rangeshort = true,
    --     view = 5,
    --     hiddenlegend = false,
    -- },
}
    

Config.DiscoverableBlips = { --still WIP
    ["burgershot_1"] = {
        JobLocked = false, -- false or name of job 'police' --locks it so only a specific job can discover this blip
        label = "Burgershot",
        coords = vector3(-499.42, 5268.11, 80.61),
        colour = 64,
        sprite = 566,
        scale = 0.5,
    },
}