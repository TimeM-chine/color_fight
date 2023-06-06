local ServerScriptService = game:GetService("ServerScriptService")
-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local gameConfig = require(game.ReplicatedStorage.configs.GameConfig)

---- events ----
local getLoginRewardEvent = game.ReplicatedStorage.RemoteEvents.getLoginRewardEvent


local loginRewardsFrameClass = {}
loginRewardsFrameClass.__index = loginRewardsFrameClass
loginRewardsFrameClass.frame = nil
loginRewardsFrameClass.connections = {}

function loginRewardsFrameClass.new(frame)
    local ins = setmetatable({}, loginRewardsFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.innerFrame = frame.basement.inner
    ins.modalFrame = frame.basement.modalFrame
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)
    ins:CheckLoginDay()
    return ins
end


function loginRewardsFrameClass:CheckLoginDay()
    local loginState = playerModule.GetPlayerOneData(dataKey.loginState)
    local nowDay = math.floor(os.time()/universalEnum.oneDay)
    local todayIndex = (nowDay - universalEnum.gameStartDay)%7 + 1  -- 1 to 7

    for i=1, todayIndex do
        local receiveBtn:ImageButton = self.innerFrame["day"..i].receiveBtn
        if loginState[i] then
            receiveBtn.received.Visible = true
        end

        if not loginState[i] and (i < todayIndex) then
            receiveBtn.missed.Visible = true
            local con = receiveBtn.missed.MouseButton1Click:Connect(function()
                localPlayer.Character.HumanoidRootPart.clickUI:Play()
                self:ReSign(i)
            end)
            table.insert(self.connections, con)
        end

        local receiveCon = receiveBtn.MouseButton1Click:Connect(function()
            localPlayer.Character.HumanoidRootPart.clickUI:Play()

            receiveBtn.received.Visible = true
            getLoginRewardEvent:FireServer(i)
            GAModule:addDesignEvent({
                eventId = `rewardsCheck:loginRewards:day{i}:normal:{localPlayer.UserId}`
            })
            uiController.SetNotification("success", "bottom")
        end)
        table.insert(self.connections, receiveCon)

    end

    for i=todayIndex+1, 7 do
        local receiveBtn:ImageButton = self.innerFrame["day"..i].receiveBtn
        local receiveCon = receiveBtn.MouseButton1Click:Connect(function()
            localPlayer.Character.HumanoidRootPart.clickUI:Play()

            uiController.SetNotification("not today", "bottom")
        end)
        table.insert(self.connections, receiveCon)
    end

end


function loginRewardsFrameClass:ReSign(day)
    self.modalFrame.Visible = true
    -- todo check text
    self.modalFrame.inner.textFrame.TextLabel.Text = `Sure to resign? Needs {gameConfig.resignCost} wins.`
    -- if confirm, check player data
    local confirmBtn:ImageButton = self.modalFrame.inner.confirmBtn
    local cancelBtn:ImageButton = self.modalFrame.inner.cancelBtn

    local con1 = confirmBtn.MouseButton1Click:Connect(function()        
        local wins = playerModule.GetPlayerOneData(dataKey.wins)
        if wins >= gameConfig.resignCost then
            self.innerFrame["day"..day].receiveBtn.received.Visible = true
            getLoginRewardEvent:FireServer(day, true)
            GAModule:addDesignEvent({
                eventId = `rewardsCheck:loginRewards:day{day}:resign:{localPlayer.UserId}`
            })
            uiController.SetNotification("success", "bottom")
        else
            uiController.SetNotification("not enough wins", "bottom")
        end
    end)

    local con2 = cancelBtn.MouseButton1Click:Connect(function()
        self.modalFrame.Visible = false
    end)

    table.insert(self.connections, con1)
    table.insert(self.connections, con2)

end

function loginRewardsFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return loginRewardsFrameClass
