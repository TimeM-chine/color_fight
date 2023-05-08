

---- classes ----


---- modules ----
local uiController = require(script.Parent.uiScripts.uiController)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)

local frame = {"lotteryFrame", "shopFrame"}



KeyboardRecall.SetClientRecall(Enum.KeyCode.Space, function()
    local t = {"top", "middle", "bottom"}
    uiController.SetNotification("wuhu yeah babe", t[math.random(1, 3)])
end)


game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 60
