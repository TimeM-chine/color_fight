-- ================================================================================
-- player cls --> client side
-- ================================================================================

---- remote functions ----
local ClientGetData = game.ReplicatedStorage.RemoteFunctions.ClientGetData

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local rewardSpeed = 0

---- enums ----
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

local PlayerClientModule = {}

function PlayerClientModule.SetPos(pos:Vector3)
    LocalPlayer.Character:MoveTo(pos)
end

function PlayerClientModule.GetPos()
    return LocalPlayer.Character.HumanoidRootPart.CFrame.Position
end

function PlayerClientModule.GetPlayerOneData(key)
    local value = ClientGetData:InvokeServer(key)
    while not value do
        value = ClientGetData:InvokeServer(key)
        task.wait(0.1)
    end
    return value
end

function PlayerClientModule.GetPlayerSpeed()
    local shoeId = PlayerClientModule.GetPlayerOneData(dataKey.chosenShoeInd)
    while not shoeId do
        shoeId = PlayerClientModule.GetPlayerOneData(dataKey.chosenShoeInd)
        task.wait(1)
    end
    shoeId = shoeId[1]
    local txt = LocalPlayer.PlayerGui.hudScreen.bgFrame.speedFrame.TextLabel.Text
    local speedBuff = tonumber(string.match(txt, "Speed buff: (%d+)%%"))
    return math.ceil(universalEnum.normalSpeed * (shoeId*10 +5 + 100 + speedBuff + rewardSpeed)/ 100)
end

function PlayerClientModule.SetRewardSpeed(value)
    rewardSpeed = value
end

return PlayerClientModule
