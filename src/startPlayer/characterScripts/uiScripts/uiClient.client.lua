-- ================================================================================
-- ui client
-- ================================================================================
---- services ----
local SocialService = game:GetService("SocialService")
local MarketplaceService = game:GetService"MarketplaceService"

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local hudBgFrame = PlayerGui.hudScreen.bgFrame
local shopBtn = hudBgFrame.inLobby.shopBtn
local onlineBtn = hudBgFrame.inLobby.onlineBtn
local buyHeartBtn = hudBgFrame.hpFrame.buyHeartBtn
local unitsFolder = PlayerGui.units
local hpFrame = hudBgFrame.hpFrame
local speedFrame = hudBgFrame.speedFrame
local friendFrame = hudBgFrame.friendFrame
local inviteBtn = speedFrame.inviteBtn
local friendNum = 0

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local perTipEvent = game.ReplicatedStorage.BindableEvents.perTipEvent
local addHealthEvent = game.ReplicatedStorage.RemoteEvents.addHealthEvent
local serverNotifyEvent = game.ReplicatedStorage.RemoteEvents.serverNotifyEvent

---- enums ----
local screenEnum = require(game.ReplicatedStorage.enums.screenEnum)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)

---- modules ----
local uiController = require(script.Parent.uiController)
local SkillModule = require(game.StarterPlayer.StarterPlayerScripts.modules.SkillModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---------------------- events -------------------------
notifyEvent.Event:Connect(function(msg, noteType)
    noteType = noteType or "middle"
    uiController.SetNotification(msg, noteType)
end)

serverNotifyEvent.OnClientEvent:Connect(function(msg, noteType)
    noteType = noteType or "middle"
    uiController.SetNotification(msg, noteType)
end)

perTipEvent.Event:Connect(function(msg)
    uiController.SetPersistentTip(msg)
end)

---------------------- buttons -------------------------
onlineBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.onlineRewardsFrame)
    GAModule:addDesignEvent({
        eventId = `pageCheck:onlineRewardsPage:{LocalPlayer.UserId}`
    })
end)

shopBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()
    uiController.PushScreen(screenEnum.shopFrame)
end)

buyHeartBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()

    print("player buy heart")
    addHealthEvent:FireServer()
    -- MarketplaceService:PromptProductPurchase(LocalPlayer, productIdEnum.heart)
end)

hudBgFrame.inGame.skillBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()

    SkillModule.UseSkill()
end)

local function canSendGameInvite(sendingPlayer)

	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

inviteBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()
    GAModule:addDesignEvent({
        eventId = `buttonCheck:inviteBtn:{LocalPlayer.UserId}`
    })
    local canInvite = canSendGameInvite(LocalPlayer)
	if canInvite then
		local success, errorMessage = pcall(function()
			SocialService:PromptGameInvite(LocalPlayer)
		end)
	end
end)


workspace.signBox.ProximityPrompt.Triggered:Connect(function()
    uiController.PushScreen(screenEnum.loginRewardsFrame)
    GAModule:addDesignEvent({
        eventId = `pageCheck:loginPage:{LocalPlayer.UserId}`
    })
end)
---------------------- hp -------------------------

local hp = LocalPlayer.Character.Humanoid.Health

if hp ~= 100 then
    for i=1, hp do
        hpFrame['hp'..i].full.Visible = true
    end

    for i= hp + 1, 6 do
        hpFrame['hp'..i].full.Visible = false
    end
end


LocalPlayer.Character.Humanoid.HealthChanged:Connect(function(health)
    for i=1, health do
        hpFrame['hp'..i].full.Visible = true
    end

    for i= health + 1, 6 do
        hpFrame['hp'..i].full.Visible = false
    end
end)


---------------------- friends -------------------------
local function onPlayerAdded(player:Player)
	if LocalPlayer:IsFriendsWith(player.UserId) then
        friendNum += 1
        GAModule:addDesignEvent({
            eventId = `inviteSuccess:{LocalPlayer.UserId}:{player.UserId}`
        })
        RemoteEvents.friendInEvent:FireServer(player.UserId)
    end
    friendFrame.TextLabel.Text = `friend num: {friendNum}`
    speedFrame.TextLabel.Text = `Speed buff: {math.min(15, friendNum*5)}%`
end

for _, player in pairs(game.Players:GetPlayers()) do
	onPlayerAdded(player)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(function(player)
    if LocalPlayer:IsFriendsWith(player.UserId) then
        friendNum -= 1
    end
    friendFrame.TextLabel.Text = `friend num: {friendNum}`
    speedFrame.TextLabel.Text = `Speed buff: {math.min(15, friendNum*5)}%`
end)
