Config = {}

Config.DebugCode = true

Config.MaxBlips = 20 --per player

Config.BlipItem = false --false or itemcode to make the blip creator as an item

Config.BlipCommand = 'blipCreator' --false or command code to make blip creator as a /command

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

Config.Scales = {
    ['Small'] = 0.5,
    ['Regular'] = 1.0,
    ['Large'] = 1.5,
}

Config.DefaultBlips = {

    -- Hope Falls
    -- Woodworking
    [1] = {
        JobLocked = false, -- false or name of job 'police'
        vector = vector3(-499.42, 5268.11, 80.61),
        text = "Woodworking",
        color = 64,
        sprite = 566,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Mechanic
    [2] = {
        vector = vector3(-578.31, 5243.25, 70.47),
        text = "Mechanic",
        color = 38,
        sprite = 446,
        scale = 0.4,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Metalworking
    [3] = {
        vector = vector3(-580.16, 5350.92, 70.21),
        text = "Metalwork",
        color = 62,
        sprite = 238,
        scale = 0.6,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Exchange
    [4] = {
        vector = vector3(-571.69, 5323.48, 70.21),
        text = "Exchange",
        color = 5,
        sprite = 277,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Firearms
    [5] = {
        vector = vector3(-585.74, 5332.4, 70.21),
        text = "Firearms",
        color = 1,
        sprite = 110,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Water
    [6] = {
        vector = vector3(-576.02, 5315.34, 70.24),
        text = "Water",
        color = 38,
        sprite = 827,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Medical
    [7] = {
        vector = vector3(-556.09, 5318.15, 74.59),
        text = "Medical",
        color = 1,
        sprite = 153,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Shop
    [8] = {
        vector = vector3(-592.17, 5312.18, 70.21),
        text = "Shop",
        color = 2,
        sprite = 52,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Barber
    [9] = {
        vector = vector3(-589.72, 5341.2, 70.22),
        text = "Barber",
        color = 8,
        sprite = 71,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },

    -- junker Town
    -- Woodworking
    [10] = {
        vector = vector3(2366.48, 3127.08, 48.29),
        text = "Woodworking",
        color = 64,
        sprite = 566,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Mechanic
    [11] = {
        vector = vector3(2330.14, 3052.54, 48.15),
        text = "Mechanic",
        color = 38,
        sprite = 446,
        scale = 0.4,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Metalworking
    [12] = {
        vector = vector3(2353.62, 3052.28, 48.15),
        text = "Metalwork",
        color = 62,
        sprite = 238,
        scale = 0.6,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Exchange
    [13] = {
        vector = vector3(2343.52, 3142.14, 48.21),
        text = "Exchange",
        color = 5,
        sprite = 277,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Firearms
    [14] = {
        vector = vector3(2349.98, 3114.55, 48.21),
        text = "Firearms",
        color = 1,
        sprite = 110,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Water
    [15] = {
        vector = vector3(2349.18, 3126.56, 48.21),
        text = "Water",
        color = 38,
        sprite = 827,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Medical
    [16] = {
        vector = vector3(2423.85, 3131.69, 48.37),
        text = "Medical",
        color = 1,
        sprite = 153,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Shop
    [17] = {
        vector = vector3(2358.66, 3120.34, 48.21),
        text = "Shop",
        color = 2,
        sprite = 52,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Clothing
    [18] = {
        vector = vector3(2339.11, 3128.76, 48.21),
        text = "Barber",
        color = 8,
        sprite = 73,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },

    -- galileo
    -- Mechanic
    [20] = {
        vector = vector3(-1779.2, 3075.74, 32.81),
        text = "Mechanic",
        color = 38,
        sprite = 446,
        scale = 0.4,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Firearms
    [23] = {
        vector = vector3(-1805.41, 2973.46, 33.22),
        text = "Firearms",
        color = 1,
        sprite = 110,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Water
    [24] = {
        vector = vector3(-1948.4, 3013.85, 32.81),
        text = "Water",
        color = 38,
        sprite = 827,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Shop
    [26] = {
        vector = vector3(-1938.99, 3019.84, 32.81),
        text = "Shop",
        color = 2,
        sprite = 52,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Surgeon
    [27] = {
        vector = vector3(-1911.46, 3046.72, 32.87),
        text = "Surgeon",
        color = 8,
        sprite = 102,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },

    -- stronghold
    -- Woodworking
    [28] = {
        vector = vector3(784.64, 1292.2, 360.3),
        text = "Woodworking",
        color = 64,
        sprite = 566,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Mechanic
    [29] = {
        vector = vector3(783.75, 1295.62, 360.3),
        text = "Mechanic",
        color = 38,
        sprite = 446,
        scale = 0.4,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Metalworking
    [30] = {
        vector = vector3(775.82, 1300.55, 360.3),
        text = "Metalwork",
        color = 62,
        sprite = 238,
        scale = 0.6,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Exchange
    [31] = {
        vector = vector3(749.31, 1280.87, 360.3),
        text = "Exchange",
        color = 5,
        sprite = 277,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Firearms
    [32] = {
        vector = vector3(979.52, -195.2, 85.48),
        text = "Firearms",
        color = 1,
        sprite = 110,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Water
    [33] = {
        vector = vector3(949.58, -178.07, 80.58),
        text = "Water",
        color = 38,
        sprite = 827,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Medical
    [34] = {
        vector = vector3(953.21, -198.04, 73.21),
        text = "Medical",
        color = 1,
        sprite = 153,
        scale = 0.7,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Shop
    [35] = {
        vector = vector3(955.96, -187.43, 79.32),
        text = "Shop",
        color = 2,
        sprite = 52,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },
    -- Tattoo
    [36] = {
        vector = vector3(975.8, -206.08, 82.73),
        text = "Tattooist",
        color = 8,
        sprite = 75,
        scale = 0.5,
        rangeshort = true,
        view = 5,
        hiddenlegend = false,
    },  
}
    