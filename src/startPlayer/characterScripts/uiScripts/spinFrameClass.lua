-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- services ----
local MarketplaceService = game:GetService"MarketplaceService"
local TweenService = game:GetService("TweenService")

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents
local remoteFunctions = game.ReplicatedStorage.RemoteFunctions

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local GameConfig = require(game.ReplicatedStorage.configs.GameConfig)

---- variables ----
local localPlayer = game.Players.LocalPlayer
local canSpin = true

local spinFrameClass = {}
spinFrameClass.__index = spinFrameClass
spinFrameClass.frame = nil
spinFrameClass.connections = {}

function spinFrameClass.new(frame)
    local ins = setmetatable({}, spinFrameClass)
    ins.frame = frame
    ins.closeBtn = frame.closeBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    ins:Init()

    return ins

end


function spinFrameClass:Init()
    local nowWins = playerModule.GetPlayerOneData(dataKey.wins)
    local winTxt = self.frame.confirmBtn.win.win.wins
    winTxt.Text = nowWins
    local con = self.frame.confirmBtn.MouseButton1Click:Connect(function()
        if not canSpin then return end
        canSpin = false
        self.frame.spinImage.Rotation = 0
        local giftIndex = remoteFunctions.Spin:InvokeServer()
        if not giftIndex then
            canSpin = true
            return
        end
        winTxt.Text = tonumber(winTxt.Text) - 2
        task.spawn(function()
            local angle = 72 * (giftIndex - 1) + math.random(0, 72)
            local spinTime = math.random(3, 6)
            local tweenInfo = TweenInfo.new(spinTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local target = {
                Rotation = 360 * math.random(20, 40) + angle
            }
            local tween = TweenService:Create(self.frame.spinImage, tweenInfo, target)
            tween:Play()

            local finalAngle = (giftIndex - 1) * 360 / #GameConfig.spinConfig + 36
            task.delay(spinTime + 0.1, function()
                if self.frame and self.frame.Visible then
                    self.frame.spinImage.Rotation = finalAngle
                    nowWins = playerModule.GetPlayerOneData(dataKey.wins)
                    winTxt.Text = nowWins
                end
                local giftItem = GameConfig.spinConfig[giftIndex].item
                if giftItem == "nothing" then
                    uiController.SetNotification("Got nothing this time.", "top")
                else
                    uiController.SetNotification(`🎇 Congratulations! You got {giftItem}`, "top")
                end
                canSpin = true
            end)

        end)
    end)

    table.insert(self.connections, con)
end


function spinFrameClass:Refresh()

end


function spinFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end
    for key, _ in self do
        self[key] = nil
    end
end


return spinFrameClass
