-- ================================================================================
-- ui client
-- ================================================================================

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local shopBtn = PlayerGui.hudScreen.bgFrame.shopBtn

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent

---- enums ----
local screenEnum = require(game.ReplicatedStorage.enums.screenEnum)

---- modules ----
local uiController = require(script.Parent.uiController)


notifyEvent.Event:Connect(function(msg, noteType)
    noteType = noteType or "middle"
    uiController.SetNotification(msg, noteType)
end)


shopBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.careerShopFrame)
end)

