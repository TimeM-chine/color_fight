local Lighting = game:GetService("Lighting")
local localPlayer = game.Players.LocalPlayer
local BasePartCls = require(game.Players.LocalPlayer.PlayerScripts.classes.BasePartCls)
local pModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local BindableEvents = game.ReplicatedStorage.BindableEvents
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)

---- main ----

local TeleportPart = setmetatable({
    destination = nil,
    isTouching = false,
    offset = Vector3.new(0, 10, 0)
}, BasePartCls)
TeleportPart.__index = TeleportPart


function TeleportPart.new(part:Part)
    local ins = setmetatable(getmetatable(TeleportPart).new(part, part.TeleportPart), TeleportPart)

    ins.destination = ins.folder.destination.Value
    local offset = ins.folder:FindFirstChild("offset")
    ins.offset = offset and offset.Value or ins.offset

    ins:Init()
    return ins
end

function TeleportPart:Init()
    local con = self.part.Touched:Connect(function(otherPart)
        if self.isTouching then return end
        if otherPart:IsDescendantOf(localPlayer.Character) then
            self.isTouching = true
            localPlayer.Character.PrimaryPart.CFrame = self.destination.CFrame + self.offset

            if self.part:FindFirstChild("resetCamera") then
                pModule.Cancel2DCamera()
            end

            if self.folder:FindFirstChild("density") then
                BindableEvents.densityEvent:Fire(self.folder.density.Value)
                -- Lighting.Atmosphere.Density = self.folder.density.Value
            end

            ---- color world ----
            if self.destination.Name == "mainCityLocation" then
                for _, part:Part in workspace.colorWorld:GetDescendants() do
                    if not part:IsA("BasePart") then continue end
                    if math.random(0, 1) > 0 then
                        part.Color = colorEnum.white
                    else
                        part.Color = colorEnum.black
                    end
                end

                local door = workspace.colorWorld.getBackDoor
                door.Part.CanTouch = false
                for _, part in door:GetChildren() do
                    part.CanCollide = false
                    part.Transparency = 1
                end

                local BlackBucket = workspace.bucketModels.BlackBucket
                BlackBucket.ProximityPrompt.Enabled = true
                BlackBucket.CanCollide = true
                BlackBucket.Transparency = 0

            end


            local music:Sound = localPlayer.Character.HumanoidRootPart:FindFirstChild("teleport")
            if music then
                music:Play()
            end
            task.delay(1, function()
                self.isTouching = false
            end)
        end
    end)

    table.insert(self.connections, con)
end


return TeleportPart
