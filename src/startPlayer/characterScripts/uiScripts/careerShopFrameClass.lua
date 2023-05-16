-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.StarterPlayer.StarterPlayerScripts.modules.PlayerClientModule)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)



local careerShopFrameClass = {}
careerShopFrameClass.__index = careerShopFrameClass
careerShopFrameClass.frame = nil
careerShopFrameClass.connections = {}

function careerShopFrameClass.new(frame)
    local ins = setmetatable({}, careerShopFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.innerFrame = ins.frame.basement.inner
    ins.scrollFrame = ins.innerFrame.ScrollingFrame
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)
    ins:CheckCareer()
    return ins

end


function careerShopFrameClass:CheckCareer()
    local career = playerModule.GetPlayerOneData(dataKey.career)
    for i=1, #career do
        local careerFrame = self.scrollFrame["career"..i]
        local confirmBtn:TextButton = careerFrame.Frame.Frame.confirm

        confirmBtn.Text = "Buy"

        local con = confirmBtn.MouseButton1Click:Connect(function()
            confirmBtn.Text = "Choose"
            uiController.SetNotification("success", "bottom")
            -- todo fire server
        end)

        table.insert(self.connections, con)
    end

end

function careerShopFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return careerShopFrameClass
