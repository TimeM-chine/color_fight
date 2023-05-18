-- ================================================================================
-- ui client
-- ================================================================================

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local hudBgFrame = PlayerGui.hudScreen.bgFrame
local shopBtn = hudBgFrame.inLobby.shopBtn
local loginBtn = hudBgFrame.inLobby.loginBtn
local buyHeartBtn = hudBgFrame.hpFrame.buyHeartBtn
local unitsFolder = PlayerGui.units
local hpFrame = hudBgFrame.hpFrame

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local perTipEvent = game.ReplicatedStorage.BindableEvents.perTipEvent
local addHealthEvent = game.ReplicatedStorage.RemoteEvents.addHealthEvent
local serverNotifyEvent = game.ReplicatedStorage.RemoteEvents.serverNotifyEvent

---- enums ----
local screenEnum = require(game.ReplicatedStorage.enums.screenEnum)

---- modules ----
local uiController = require(script.Parent.uiController)
local SkillModule = require(game.StarterPlayer.StarterPlayerScripts.modules.SkillModule)


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


loginBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.loginRewardsFrame)
end)

shopBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.shopFrame)
end)

buyHeartBtn.MouseButton1Click:Connect(function()
    print("player buy heart")
    addHealthEvent:FireServer()
end)

hudBgFrame.inGame.skillBtn.MouseButton1Click:Connect(function()
    SkillModule.UseSkill()
end)


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
