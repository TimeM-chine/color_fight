-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)



local shoeShopFrameClass = {}
shoeShopFrameClass.__index = shoeShopFrameClass
shoeShopFrameClass.frame = nil
shoeShopFrameClass.connections = {}

function shoeShopFrameClass.new(frame)
    local ins = setmetatable({}, shoeShopFrameClass)
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


function shoeShopFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return shoeShopFrameClass
