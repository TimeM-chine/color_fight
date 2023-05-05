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
    return ClientGetData:InvokeServer(key)
end


return PlayerClientModule
