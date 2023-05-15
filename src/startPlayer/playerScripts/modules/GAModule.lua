---- events ----
local GAEvent = game.ReplicatedStorage.RemoteEvents.GAEvent


local GAModule = {}


function GAModule.ReportEvent(category, action, label, value)
    GAEvent:FireServer(category, action, label, value)
end

return GAModule
