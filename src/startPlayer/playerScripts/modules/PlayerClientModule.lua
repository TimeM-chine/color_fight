-- ================================================================================
-- player cls --> client side
-- ================================================================================

---- remote functions ----
local ClientGetData = game.ReplicatedStorage.RemoteFunctions.ClientGetData

---- services ----
local TweenService = game:GetService("TweenService")

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local rewardSpeed = 0
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local cameraStep

---- enums ----
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

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

function PlayerClientModule.GetPlayerSpeed()
    local shoeId = PlayerClientModule.GetPlayerOneData(dataKey.chosenShoeInd)
    while not shoeId do
        shoeId = PlayerClientModule.GetPlayerOneData(dataKey.chosenShoeInd)
        task.wait(1)
    end
    shoeId = shoeId[1]
    local txt = LocalPlayer.PlayerGui.hudScreen.bgFrame.speedFrame.TextLabel.Text
    local speedBuff = tonumber(string.match(txt, "Speed buff: (%d+)%%"))
    return math.ceil(universalEnum.normalSpeed * (shoeId*10 +5 + 100 + speedBuff + rewardSpeed)/ 100)
end

function PlayerClientModule.SetRewardSpeed(value)
    rewardSpeed = value
end

function PlayerClientModule.Set2DCamera()
    camera.CameraType = Enum.CameraType.Scriptable
    local offset = Vector3.new(45, 10, 0)
    local part = LocalPlayer.Character.HumanoidRootPart
    local tweenInfo = TweenInfo.new(2)
    local target = {
        CFrame = CFrame.new(part.CFrame.Position + offset, part.CFrame.Position)
    }
    local tween = TweenService:Create(camera, tweenInfo, target)
    tween:Play()
    task.wait(2)
    cameraStep = game:GetService("RunService").Stepped:Connect(function(time, deltaTime)
        camera.CFrame = CFrame.new(part.CFrame.Position + offset, part.CFrame.Position)
    end)
end

function PlayerClientModule.Cancel2DCamera()
    camera.CameraType = Enum.CameraType.Custom
    if cameraStep then 
        cameraStep:Disconnect()
    end
end

function PlayerClientModule.TurnOnTopLight()
    local Cone = game.ReplicatedStorage:FindFirstChild("Cone"):Clone()
    local hrp = LocalPlayer.Character.HumanoidRootPart
    Cone.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
    Cone.WeldConstraint.Part0 = Cone
    Cone.WeldConstraint.Part1 = hrp
    Cone.Parent = workspace
end

function PlayerClientModule.TurnOffTopLight()
    local cone = workspace:FindFirstChild('Cone')
    if cone then
        cone:Destroy()
    end
end


return PlayerClientModule
