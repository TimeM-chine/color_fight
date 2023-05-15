-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.StarterPlayer.StarterPlayerScripts.modules.PlayerClientModule)

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- enums ----
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)


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
        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    for i=1, 7 do
        local receiveBtn:ImageButton = ins.innerFrame["day"..i].receiveBtn
        local receiveCon = receiveBtn.MouseButton1Click:Connect(function()
            receiveBtn.ImageButton.Visible = true
            -- TODO send to server
        end)
        table.insert(ins.connections, receiveCon)

    end

    return ins

end


function loginRewardsFrameClass:CheckLoginDay()
    local lastSignDay = playerModule.GetPlayerOneData(dataKey.lastSignDay)
    local signInDay = playerModule.GetPlayerOneData(dataKey.signInDay)
    local nowDay = math.floor(os.time()/universalEnum.oneDay)
    if nowDay - lastSignDay > 1 then
        signInDay = 1
    end
    
    ----- todo 处理签到问题

end


function loginRewardsFrameClass:ReSign(day)
    self.modalFrame.Visible = true
    -- todo check text
    self.modalFrame.inner.textFrame.TextLabel.Text = "test"
    -- if confirm, check player data

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
