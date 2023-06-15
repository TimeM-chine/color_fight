-- ================================================================================
-- watch server --> server side
-- ================================================================================
local localPlayer = game.Players.LocalPlayer
local watchingPlayers = {3148115551}
local trackEvent = game.ReplicatedStorage.RemoteEvents.trackingPlayer

if table.find(watchingPlayers, localPlayer.UserId) then
    if not localPlayer.Character then localPlayer.CharacterAdded:Wait() end
    localPlayer.Character:WaitForChild("colorString")
    local hudBgFrame = localPlayer.PlayerGui:WaitForChild("hudScreen").bgFrame

    while task.wait(10) do
        local pos = localPlayer.Character:GetPivot().Position
        trackEvent:FireServer({
            color = localPlayer.Character.colorString.Value,
            pos = {pos.X, pos.Y, pos.Z},
            pallets = hudBgFrame.inGame.pallet.TextLabel.Text,
            lastDoorCollision = workspace.lastDoors.level1.CanCollide,
        wallCollision = workspace.spawn.Wall.wall.wall.CanCollide,
            health = localPlayer.Character.Humanoid.Health,
            speed = localPlayer.Character.Humanoid.WalkSpeed
        })
    end

end

