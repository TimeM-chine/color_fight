local config = {}

config.resignCost = 3
config.onlineRewardsStart = 1685289600
config.onlineRewardsEnd = 1687017600 -- 2023-06-18 00:00:00
config.cdkExpireTime = {
    YOLDLO = 1687449600,
    Flashbackjnr = 1687449600,
    Froosting = 1690732800,
}
config.careerWinPrice = {
    3, 5, 7, 9
}
config.badges = {
    firstPlay = 2147976617,
    firstBucket = 2147976680,
    firstWinLv1 = 2147976804,
    firstWinLv2 = 2147977688,
}
config.tailConfig = {
    [1] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 1, 1)),
        winPrice = 0
    },
    [2] = {
        type = "color",
        color = ColorSequence.new(Color3.new(0, 1, 0)),
        winPrice = 1
    },
    [3] = {
        type = "color",
        color = ColorSequence.new(Color3.new(0.560784, 0.988235, 0.003921)),
        winPrice = 5
    },
    [4] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 1, 0)),
        winPrice = 10
    },
    [5] = {
        type = "color",
        color = ColorSequence.new(Color3.new(0, 0.6, 1)),
        winPrice = 15
    },
    [6] = {
        type = "color",
        color = ColorSequence.new(Color3.new(0, 0, 1)),
        winPrice = 25
    },
    [7] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 0, 1)),
        winPrice = 45
    },
    [8] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 0.6, 0)),
        winPrice = 75
    },
    [9] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 0.317647, 0)),
        winPrice = 150
    },
    [10] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 0, 0)),
        winPrice = 300
    },
    [11] = {
        type = "color",
        color = ColorSequence.new(Color3.new(1, 0, 0.584313)),
        winPrice = 500
    },
    [12] = {
        type = "color",
        color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 190, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 0, 255))
        },
        winPrice = nil
    },
}

config.spinConfig = {

    [1] = {
        item = "career",
        weight = 0.5
    },
    [2] = {
        item = "win",
        count = 10,
        weight = 5,
    },
    [3] = {
        item = "nothing",
        weight = 83.5
    },
    [4] = {
        item = "win",
        count = 5,
        weight = 10,
    },
    [5] = {
        item = "tail",
        weight = 1,
    },

}


config.testPlace1Id = 13542969609
config.testPlace2Id = 13805481134

config.officialPlace1Id = 13360219692
config.officialPlace2Id = 13921717039

return config
