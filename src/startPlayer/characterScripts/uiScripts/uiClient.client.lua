-- ================================================================================
-- ui client
-- ================================================================================


---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent

---- modules ----
local uiController = require(script.Parent.uiController)


notifyEvent.Event:Connect(function(msg)
    uiController.SetNotification(msg, "middle")
end)
