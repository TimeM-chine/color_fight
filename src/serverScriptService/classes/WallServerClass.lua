local ProximityPromptService = game:GetService("ProximityPromptService")
-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- variables ----
local wallInsList = {}
local PlayerService = game.Players
local colorCheck = {}

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

    -- self.touchCon = self.wall.Touched:Connect(function(otherPart)
    --     local character = otherPart:FindFirstAncestorWhichIsA("Model")
    --     if not character then return end

    --     local player = PlayerService:GetPlayerFromCharacter(character)
    --     if not player then return end
    --     if self.playerDebounce[player] then return end

    --     self.playerDebounce[player] = true

    --     if character.colorString.Value == wall.colorString.Value then
    --         character.isHiding.Value = true
    --         character.Highlight.Enabled = true
    --     end
    -- end)

    -- self.touchEndCon = self.wall.TouchEnded:Connect(function(otherPart)
    --     local character = otherPart:FindFirstAncestorWhichIsA("Model")
    --     if not character then return end

    --     local player = PlayerService:GetPlayerFromCharacter(character)
    --     if not player then return end
    --     -- if not self.playerDebounce[player] then return end
    --     if character.colorString.Value ~= wall.colorString.Value then
    --         return
    --     end
    --     task.wait(0.2)
        
    --     local param = OverlapParams.new()
    --     param.FilterDescendantsInstances = character:GetChildren()
    --     param.FilterType = Enum.RaycastFilterType.Include
    --     local parts = workspace:GetPartBoundsInBox(
    --         self.wall.CFrame, self.wall.Size, param
    --     )
    --     -- print("parts", parts)

    --     param = OverlapParams.new()
    --     param.FilterDescendantsInstances = workspace.walls:GetDescendants()
    --     param.FilterType = Enum.RaycastFilterType.Include
    --     local cf, size = character:GetBoundingBox()
    --     local playerContact = workspace:GetPartBoundsInBox(cf, size, param)
    --     -- print("playerContact", playerContact)
    --     if #parts == 0 then
    --         for _, conPart in playerContact do
    --             if conPart.colorString.Value == character.colorString.Value then
    --                 return
    --             end
    --         end
    --         character.isHiding.Value = false
    --         self.playerDebounce[player] = false
    --         character.Highlight.Enabled = false
    --     end
    -- end)

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
    local colorListCopy = table.clone(colorList)

    for i=-1, 1, 2 do
        local neighborColor = colorCheck[wall.CFrame.Position + Vector3.new(15*i, 0, 0)]
        if neighborColor then
            local ind = table.find(colorListCopy, neighborColor)
            table.remove(colorListCopy, ind)
        end
    end

    for j = -1,1,2 do
        local neighborColor = colorCheck[wall.CFrame.Position + Vector3.new(0, 0, 15*j)]
        if neighborColor then
            local ind = table.find(colorListCopy, neighborColor)
            table.remove(colorListCopy, ind)
        end
    end


    local colorName = colorListCopy[math.random(1, #colorListCopy)]
    wall.Color = colorValue[colorName]

    CreateModule.CreateValue("StringValue", "colorString", colorName, wall)

    wallInsList[wall] = wallIns
    colorCheck[wall.CFrame.Position] = colorName
end




return WallServerClass
