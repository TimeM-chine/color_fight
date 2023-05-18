-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.StarterPlayer.StarterPlayerScripts.modules.PlayerClientModule)
local SkillModule = require(game.StarterPlayer.StarterPlayerScripts.modules.SkillModule)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)


local shopFrameClass = {}
shopFrameClass.__index = shopFrameClass
shopFrameClass.frame = nil
shopFrameClass.connections = {}

function shopFrameClass.new(frame)
    local ins = setmetatable({}, shopFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = frame.closeBtn
    ins.shoeShopBtn = frame.shoeShopBtn
    ins.careerShopBtn = frame.careerShopBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)


    con = ins.shoeShopBtn.MouseButton1Click:Connect(function()
        ins:OpenShoeShop()
    end)
    table.insert(ins.connections, con)


    con = ins.careerShopBtn.MouseButton1Click:Connect(function()
        ins:CheckCareer()
        ins:OpenCareerShop()
    end)
    table.insert(ins.connections, con)


    return ins

end


function shopFrameClass:CheckCareer()
    local career = playerModule.GetPlayerOneData(dataKey.career)
    for i=1, #career do
        local careerFrame = self.frame.careerShopFrame.ScrollingFrame["career"..i]
        local confirmBtn:TextButton = careerFrame.Frame.Frame.confirm
        local con
        if career[i] then
            confirmBtn.Text = "Choose"
        else
            confirmBtn.Text = "Buy"
        end

        con = confirmBtn.MouseButton1Click:Connect(function()
            if confirmBtn.Text == "Buy" then
                print("player want to buy career", i)
                confirmBtn.Text = "Choose"
            else
                print("player choose career", i)
                SkillModule.SetSkillId(i)
            end
        end)

        table.insert(self.connections, con)
    end

end

function shopFrameClass:DestroyIns()
    -- print(self, "destroy")
    -- for _, con in self.connections do
    --     con:Disconnect()
    -- end

    for key, _ in self do
        self[key] = nil
    end
end

function shopFrameClass:OpenShoeShop()
    self.frame.careerShopFrame.Visible = false
    self.frame.shoeShopFrame.Visible = true
end

function shopFrameClass:OpenCareerShop()
    self.frame.careerShopFrame.Visible = true
    self.frame.shoeShopFrame.Visible = false
end

return shopFrameClass
