-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.StarterPlayer.StarterPlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

---- functions ----


---- variables ----
local localPlayer = game.Players.LocalPlayer

---- events ----

local wantLikeFrameClass = {}
wantLikeFrameClass.__index = wantLikeFrameClass
wantLikeFrameClass.frame = nil
wantLikeFrameClass.connections = {}

function wantLikeFrameClass.new(frame)
    local ins = setmetatable({}, wantLikeFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.connections = {}

    task.delay(3, function()
        ins:DestroyIns()
        uiController.PopScreen()
    end)

    return ins

end





function wantLikeFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return wantLikeFrameClass
