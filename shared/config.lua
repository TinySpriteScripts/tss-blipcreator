Config = {
    System = {
        Debug = true,            -- set true to view target/ped areas
        Menu = "ox",            -- "qb", "ox"
        Notify = "ox",            -- "qb", "ox", "esx, "okok", "gta"
        ProgressBar = "ox",     -- "qb", "ox"
    },
    Crafting = { --only here for bridge support
        showItemBox = true,--will only show if your inventory supports it
    },
    Options = {
        AllowSharing = true,
        SharingDistance = 20.0, -- must be float
        MaxBlips = 20, -- per player
        AllowPinging = true,--allows players to ping their blip (putting a small radius glow effect around it) (only visible to them)
        PingBlipTimer = 5,--how many seconds the player blip with "glow" until returning back to normal
        BlipPingSprite = 161,--flashing blip. change if wanted
        AllowSetGPS = true,--allows players to set GPS waypoint on the blip from menu
        AllowFastTravel = false,--alot of people wont want this but its there for those that do
        BlipItem = 'gps_beacon',--false or itemcode to make the blip creator as an item
        BlipCreationRequiresThisItem = false,--either false for no item needed to make blip or itemcode that is required
    },
    DefaultBlips = {

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
    },
    Discovery = { -- not currently working yet
        ShowDiscoveryUI = {
            Blip = true,
            Zone = true,
        },
        BlipDiscoveryRange = 30.0,
        Blips = {
            ["burgershot_1"] = {
                JobLocked = false, -- false or name of job 'police' --locks it so only a specific job can discover this blip
                label = "Burgershot",
                coords = vector3(-499.42, 5268.11, 80.61),
                colour = 64,
                sprite = 566,
                scale = 0.5,
            },
        },
    },
    BlipOptions = {
        Sprites = { --sprite name followed by the number code of sprite (will only show these sprites as available)
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
        },
        Colours = { --list of available blip colours
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
        },
        Scales = { --list of available sizes you want players to use
            ['Small'] = 0.5,
            ['Regular'] = 1.0,
            ['Large'] = 1.5,
        },
    },
}