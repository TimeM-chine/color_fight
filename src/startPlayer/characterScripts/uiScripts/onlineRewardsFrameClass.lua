-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)



local onlineRewardsFrameClass = {}
onlineRewardsFrameClass.__index = onlineRewardsFrameClass
onlineRewardsFrameClass.frame = nil
onlineRewardsFrameClass.connections = {}

function onlineRewardsFrameClass.new(frame)
    local ins = setmetatable({}, onlineRewardsFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    return ins

end


function onlineRewardsFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return onlineRewardsFrameClass
