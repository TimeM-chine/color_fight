-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)

---- variables ----
local localPlayer = game.Players.LocalPlayer


local shopFrameClass = {}
shopFrameClass.__index = shopFrameClass
shopFrameClass.frame = nil
shopFrameClass.connections = {}

function shopFrameClass.new(frame)
    local ins = setmetatable({}, shopFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = frame.closeBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    return ins

end


function shopFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return shopFrameClass
