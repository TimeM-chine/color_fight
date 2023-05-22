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


---- variables ----
local localPlayer = game.Players.LocalPlayer
local timeTable = {
    10*universalEnum.oneMinute,
    30*universalEnum.oneMinute,
    60*universalEnum.oneMinute,
    90*universalEnum.oneMinute,
    120*universalEnum.oneMinute,
}


---- events ----
local getOnlineRewardEvent = game.ReplicatedStorage.RemoteEvents.getOnlineRewardEvent

local onlineRewardsFrameClass = {}
onlineRewardsFrameClass.__index = onlineRewardsFrameClass
onlineRewardsFrameClass.frame = nil
onlineRewardsFrameClass.connections = {}

function onlineRewardsFrameClass.new(frame)
    local ins = setmetatable({}, onlineRewardsFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.innerFrame = frame.basement.inner
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    ins:CheckOnlineTime()
    return ins

end

function onlineRewardsFrameClass:CheckOnlineTime()
    local lastLoginTimeStamp = playerModule.GetPlayerOneData(dataKey.lastLoginTimeStamp)
    local receivedOnlineTime = playerModule.GetPlayerOneData(dataKey.receivedOnlineTime)
    for i = 1, 5 do
        if receivedOnlineTime[i] then
            self.innerFrame['reward'..i].btn.received.Visible = true
        else
            local con = self.innerFrame['reward'..i].btn.MouseButton1Click:Connect(function()
                if os.time() - lastLoginTimeStamp > timeTable[i] then
                    getOnlineRewardEvent:FireServer(i)
                    self.innerFrame['reward'..i].btn.received.Visible = true
                else
                    uiController.SetNotification(`Not up to time.`)
                end
            end)

            table.insert(self.connections, con)
        end
    end


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
