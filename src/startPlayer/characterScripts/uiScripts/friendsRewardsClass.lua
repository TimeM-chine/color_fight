-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================
---- services ----
local SocialService = game:GetService("SocialService")

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local numTable = {1, 3, 7, 10 ,15, 20, 30, 35, 40}

---- variables ----
local localPlayer = game.Players.LocalPlayer

---- events ----
local getFriendRewards = game.ReplicatedStorage.RemoteEvents.getFriendRewards

local friendsRewardsClass = {}
friendsRewardsClass.__index = friendsRewardsClass
friendsRewardsClass.frame = nil
friendsRewardsClass.connections = {}

function friendsRewardsClass.new(frame)
    local ins = setmetatable({}, friendsRewardsClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.innerFrame = frame.basement.inner
    ins.closeBtn = ins.frame.basement.closeBtn
    ins.scroll = ins.innerFrame.scroll
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)

    ins:CheckFriends()
    return ins

end

local function canSendGameInvite(sendingPlayer)

	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

function friendsRewardsClass:CheckFriends()
    local friendsInvitedNum = playerModule.GetPlayerOneData(dataKey.friendsInvitedNum)
    local friendsRewards = playerModule.GetPlayerOneData(dataKey.friendsRewards)
    for i = 1, 9 do
        if friendsInvitedNum >= numTable[i] then
            self.scroll['Frame'..i].Frame.btn.Text = "receive"
        end

        if friendsRewards[i] then
            self.scroll['Frame'..i].Frame.btn.Text = "received"
            self.scroll['Frame'..i].Frame.btn.BackgroundTransparency = 1
        end
        -- print(self.scroll['Frame'..i].Frame.btn.Text)
        local con = self.scroll['Frame'..i].Frame.btn.MouseButton1Click:Connect(function()
            local txt = self.scroll['Frame'..i].Frame.btn.Text
            if txt == "invite" then
                local canInvite = canSendGameInvite(localPlayer)
                if canInvite then
                    local success, errorMessage = pcall(function()
                        SocialService:PromptGameInvite(localPlayer)
                    end)
                end
            elseif txt == "receive" then
                getFriendRewards:FireServer(i)
                self.scroll['Frame'..i].Frame.btn.Text = "received"
                self.scroll['Frame'..i].Frame.btn.BackgroundTransparency = 1
            end
        end)

        table.insert(self.connections, con)
    end



end

function friendsRewardsClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end



return friendsRewardsClass
