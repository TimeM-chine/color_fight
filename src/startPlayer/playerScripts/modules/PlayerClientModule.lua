-- ================================================================================
-- player cls --> client side
-- ================================================================================

---- remote functions ----
local ClientGetData = game.ReplicatedStorage.RemoteFunctions.ClientGetData

---- variables ----
local LocalPlayer = game.Players.LocalPlayer

local PlayerClientModule = {}

function PlayerClientModule.SetPos(pos:Vector3)
    LocalPlayer.Character:MoveTo(pos)
end

function PlayerClientModule.GetPos()
    return LocalPlayer.Character.HumanoidRootPart.CFrame.Position
end

function PlayerClientModule.GetPlayerOneData(key)
    local value = ClientGetData:InvokeServer(key)
    while not value do
        value = ClientGetData:InvokeServer(key)
        task.wait(0.1)
    end
    return value
end


return PlayerClientModule
