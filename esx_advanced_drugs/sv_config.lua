config = {}
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
--[[
    recipe:
        You can define here the recipes for anything you want, 
        with the minimum amount of each ingredient, and the maximum one.

        Also, you define the perfect amount of each ingredient and if the client uses all the perfect values creating a drug,
        it will give config.perfectRecipeReward items instead of config.baseRecipeReward
        (so don't give the perfect recipe to anyone, people should find it after many tries)

    price:
        This will be the price of each x1 drug the player will sell
    
    account:
        This will be the account where the player receives money

    baseRecipeReward:
        This will be the quantity of drug that will be gave each time the player crafts the drug with all ingredients
        between the min and max quantity, but not all ingredients are in the perfect quantities

    perfectRecipeReward:
        This will be the quantity of drug that will be gave each time the player crafts the drug with ALL ingredients in perfect quantities

    allowedLabs:
        Labs where the player can craft the drug, you have to use the same number of the config.Labs in cl_config.lua

    drugType:
        How the player will assume the drug, can be:
            'drink'
            'pill'
            'smoke'

    drugEffects:
        Effects drug will produce, can be:
            'pink_visual'
            'visual_shaking'
            'drunk_walk'
            'confused_visual'
            'green_visual'
    
    effectsDuration:
        Seconds the effects will last, if the player assumes a drug more than once the duration will be added each time
]]

config.drugs = {
    drug_lean = {
        recipe = {
            ["drink_sprite"] = {min = 1, max = 3, perfect = 2, loseOnUse = true},
            ["codeine"] = {min = 2, max = 4, perfect = 3, loseOnUse = true},
            ["jolly_ranchers"] = {min = 10, max = 15, perfect = 12, loseOnUse = true},
            ["ice"] = {min = 4, max = 8, perfect = 7, loseOnUse = true},
        },

        price = 800,
        account = "black_money",

        baseRecipeReward = 1, 
        perfectRecipeReward = 2, 

        allowedLabs = {
            [1] = true,
            [2] = true,
        },

        drugType = "drink",

        drugEffects = {
            'pink_visual',
            'visual_shaking',
        },

        effectsDuration = 120
    },

    drug_meth = {
        recipe = {
            ["red_sulfur"] = {min = 15, max = 30, perfect = 23, loseOnUse = true},
            ["muriatic_acid"] = {min = 1, max = 5, perfect = 2, loseOnUse = true},
            ["liquid_sulfur"] = {min = 5, max = 10, perfect = 6, loseOnUse = true},
            ["water"] = {min = 10, max = 20, perfect = 18, loseOnUse = true},
            ["ammonium_nitrate"] = {min = 4, max = 12, perfect = 8, loseOnUse = true},
            ["sodium_hydroxide"] = {min = 1, max = 3, perfect = 2, loseOnUse = true},
            ["pseudoefedrine"] = {min = 18, max = 23, perfect = 18, loseOnUse = true},
        },

        price = 3600, -- Price of the drug when sold
        account = "black_money", -- The account where the player will receive money when selling drugs

        baseRecipeReward = 1, -- Base reward if the player, uses each ingredient between the minimum and the maximum, without having everything in perfect quantities
        perfectRecipeReward = 2, -- Better reward if the player, uses rights ingredients, each one in the perfect quantity

        allowedLabs = {
            [1] = true,
            [2] = true,
        },

        drugType = "smoke",

        drugEffects = {
            'confused_visual',
            'visual_shaking',
            'drunk_walk'
        },

        effectsDuration = 120
    },

    drug_ecstasy = {
        recipe = {
            ["carbon"] = {min = 1, max = 4, perfect = 1, loseOnUse = true},
            ["hydrogen"] = {min = 2, max = 7, perfect = 3, loseOnUse = true},
            ["nitrogen"] = {min = 5, max = 10, perfect = 4, loseOnUse = true},
            ["oxygen"] = {min = 8, max = 12, perfect = 11, loseOnUse = true},
            ["jolly_ranchers"] = {min = 2, max = 7, perfect = 4, loseOnUse = true},
        },

        price = 1500,
        account = "black_money",

        baseRecipeReward = 1, 
        perfectRecipeReward = 2,
        
        allowedLabs = {
            [1] = true,
            [2] = true,
        },

        drugType = "pill",

        drugEffects = {
            'pink_visual',
        },

        effectsDuration = 120
    },

    drug_lsd = {
        recipe = {
            ["carbon"] = {min = 8, max = 12, perfect = 11, loseOnUse = true},
            ["hydrogen"] = {min = 1, max = 2, perfect = 2, loseOnUse = true},
            ["nitrogen"] = {min = 3, max = 16, perfect = 6, loseOnUse = true},
            ["oxygen"] = {min = 3, max = 8, perfect = 5, loseOnUse = true},
        },

        price = 2000,
        account = "black_money",

        baseRecipeReward = 1, 
        perfectRecipeReward = 2,

        allowedLabs = {
            [1] = true,
            [2] = true,
        },

        drugType = "pill",

        drugEffects = {
            'visual_shaking',
            'green_visual'
        },

        effectsDuration = 120
    },
}

-- Define the quantity of each item you harvest each time (if not defined here, the default quantity will be 1)
config.ingredientQuantityOnPickup = {
    ["codeine"] = 20,
    ["liquid_sulfur"] = 20,
    ["ammonium_nitrate"] = 20,
    ["sodium_hydroxide"] = 20,
    ["pseudoefedrine"] = 20,
    ["carbon"] = 20,
    ["hydrogen"] = 20,
    ["nitrogen"] = 20,
    ["oxygen"] = 20,
}

-- Remove items if wrong recipes
config.removeOnError = false

config.minNPCSellQuantity = 2
config.maxNPCSellQuantity = 10

config.accountFromNPCSell = "black_money"
config.sellToNPCChancesToAccept = 80 -- 80% probabilities that the NPC will accept the drug

config.minimumPoliceToSell = 0 -- Minimum police online required to sell