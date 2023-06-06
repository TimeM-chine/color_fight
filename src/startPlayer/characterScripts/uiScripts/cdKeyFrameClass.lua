-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

---- functions ----
local Redeem = game.ReplicatedStorage.RemoteFunctions.Redeem


---- variables ----
local localPlayer = game.Players.LocalPlayer

---- events ----
local BindableEvents = game.ReplicatedStorage.BindableEvents

local cdKeyFrameClass = {}
cdKeyFrameClass.__index = cdKeyFrameClass
cdKeyFrameClass.frame = nil
cdKeyFrameClass.connections = {}

function cdKeyFrameClass.new(frame)
    local ins = setmetatable({}, cdKeyFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.innerFrame = frame.basement.inner
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.confirmBtn = ins.innerFrame.confirm
    ins.textBox = ins.innerFrame.TextBox
    ins.itemIcon = ins.innerFrame.itemIcon

    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    con = ins.confirmBtn.MouseButton1Click:Connect(function()
        if ins.confirmBtn.Text == "Redeem" then
            local keyInput = ins.textBox.Text
            local res, image, text = Redeem:InvokeServer(keyInput)
            if res == "used" then
                BindableEvents.notifyEvent:Fire("The key is used.", "top")
            elseif res == "wrong key" then
                BindableEvents.notifyEvent:Fire("Wrong key.", "top")
            elseif res == "success" then
                ins.confirmBtn.Text = "Confirm"
                ins.textBox.Visible = false
                ins.itemIcon.Visible = true
                --- todo 设置图片
                ins.itemIcon.Image = image
                ins.itemIcon.TextLabel.Text = text
            end
        elseif ins.confirmBtn.Text == "Confirm" then
            ins.confirmBtn.Text = "Redeem"
            ins.textBox.Text = "cdKey here"
            ins.textBox.Visible = true
            ins.itemIcon.Visible = false
        end
    end)

    table.insert(ins.connections, con)
    return ins

end


function cdKeyFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return cdKeyFrameClass
