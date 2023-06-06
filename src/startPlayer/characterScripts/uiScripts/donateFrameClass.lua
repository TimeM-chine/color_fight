-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- services ----
local MarketplaceService = game:GetService"MarketplaceService"

---- modules ----
local uiController = require(script.Parent.uiController)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)

---- functions ----

---- variables ----
local localPlayer = game.Players.LocalPlayer

local donateFrameClass = {}
donateFrameClass.__index = donateFrameClass
donateFrameClass.frame = nil
donateFrameClass.connections = {}

function donateFrameClass.new(frame)
    local ins = setmetatable({}, donateFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.donateFrame = frame.basement.inner.inner.donateFrame
    ins.closeBtn = ins.frame.basement.closeBtn

    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    for i = 1, 4 do
        local btn = ins.donateFrame['btnUnit'..i].TextButton
        con = btn.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(localPlayer, productIdEnum.donateIds[i])
        end)

        table.insert(ins.connections, con)
    end

    return ins

end


function donateFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return donateFrameClass
