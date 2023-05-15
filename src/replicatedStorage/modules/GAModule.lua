---- modules ----
local GA = require(153590792)

---- events ----
local GAEvent = game.ReplicatedStorage.RemoteEvents.GAEvent



---- variables ----
local config = {
	-- Report or omit script errors (set as 'true' to omit)
	DoNotReportScriptErrors = true,
	-- Report or omit a 'ServerStartup' action when a server starts (set as 'true' to omit)
	DoNotTrackServerStart = true,
	-- Report or omit user visits under the 'Visit' action (set as 'true' to omit)
	DoNotTrackVisits = true
}

---- init ----
GA.Init("UA-262047911-1", config)

local GAModule = {}


---- APIs ----
function GAModule.ReportEvent(category, action, label, value)
	local suc, res = pcall(function()
		GA.ReportEvent(category, action, label, value)
	end)
    if not suc then
        warn(`GA report failed, res: {res}`)
    end
end

GAEvent.OnServerEvent:Connect(function(player, category, action, label, value)
    GAModule.ReportEvent(category, action, label, value)
end)

return GAModule
