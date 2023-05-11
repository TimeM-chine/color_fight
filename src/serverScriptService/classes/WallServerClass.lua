local ProximityPromptService = game:GetService("ProximityPromptService")
-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- variables ----
local wallInsList = {}
local PlayerService = game.Players

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue


local WallServerClass = {}
WallServerClass.__index = WallServerClass
WallServerClass.tagName = "Wall"
WallServerClass.wall = nil
WallServerClass.touchCon  = nil
WallServerClass.touchEndCon = nil
WallServerClass.playerDebounce = {}

function WallServerClass.new(wall:Part)
	local self = setmetatable({}, WallServerClass)
	self.wall = wall

    self.touchCon = self.wall.Touched:Connect(function(otherPart)
        local character = otherPart:FindFirstAncestorWhichIsA("Model")
        if not character then return end

        local player = PlayerService:GetPlayerFromCharacter(character)
        if not player then return end
        if self.playerDebounce[player] then return end

        self.playerDebounce[player] = true

        if character.colorString.Value == wall.colorString.Value then
            character.isHiding.Value = true
        end
    end)

    self.touchEndCon = self.wall.TouchEnded:Connect(function(otherPart)
        local character = otherPart:FindFirstAncestorWhichIsA("Model")
        if not character then return end

        local player = PlayerService:GetPlayerFromCharacter(character)
        if not player then return end
        -- if not self.playerDebounce[player] then return end
        task.wait(0.2)
        local param = OverlapParams.new()
        param.FilterDescendantsInstances = character:GetChildren()
        param.FilterType = Enum.RaycastFilterType.Include
        local parts = workspace:GetPartBoundsInBox(
            self.wall.CFrame, self.wall.Size, param
        )
        -- print("parts", parts)
        if #parts == 0 then
            character.isHiding.Value = false
        end
    end)

	return self
end

function WallServerClass.OnRemoved(wall)
    local wallIns = wallInsList[wall]
    for key, _ in wallIns do
        wallIns[key] = nil
    end
    if wallIns.touchCon then
        wallIns.touchCon:Disconnect()
    end
    if wallIns.touchEndCon then
        wallIns.touchEndCon:Disconnect()
    end

    wallInsList[wall] = nil
end

function WallServerClass.OnAdded(wall:Part)
    local wallIns = WallServerClass.new(wall)
    local colorName = colorList[math.random(1, 7)]
    wall.Color = colorValue[colorName]

    CreateModule.CreateValue("StringValue", "colorString", colorName, wall)

    wallInsList[wall] = wallIns
end


return WallServerClass
