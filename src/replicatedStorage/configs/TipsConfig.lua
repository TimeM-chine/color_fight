local tipsConfig = {}

tipsConfig.mainCity = "To activate, spray paint on the checkpoint's main gate"
tipsConfig.beforeFirstBucket = "Pick up the purple paint"
tipsConfig.beforeFirstColorDoor = "Find the door that requires purple paint"

tipsConfig.loseColor = {
    orange = nil,
    purple = "Now you can't hide behind the purple wall",
    red = nil,
    green = nil,
    blue = nil,
    cyan = nil,
    yellow = nil,
    white = nil,
    black = nil, -- empty
}

tipsConfig.getColor = {
    orange = nil,
    purple = "Find the door that requires purple paint",
    red = nil,
    green = nil,
    blue = nil,
    cyan = nil,
    yellow = nil, 
    white = nil,
    black = nil, -- empty
}

tipsConfig.getTool = {
    keys = "Unlock the door, I believe you remember where it is.",
    shovel = "Dig open the dirt pile...",
    crowbar = "Prise open those wooden planks.",
    cassette = "Looking for a game console, let's play a game.",
    musicScore = "I think you need a piano to play it.",
    spanner = "Unscrew the screws of the iron door."
}

tipsConfig.pallets = {
    [1] = "Good!",
    [2] = "Too easy!",
    [4] = "You are indeed an adventurer",
    [6] = "It's just a maze",
    [8] = "No problem at all",
    [10] = "Oh my god, you must be a genius.",
    [12] = "nice! please continue",
    [14] = "Just one final step left",
    [15] = "Almost there!"
}

tipsConfig.Win = "Return to the starting point and unlock the next level!"

return tipsConfig
