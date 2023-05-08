-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- variables ----
local wallInsList = {}

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue


local WallServerClass = {}
WallServerClass.__index = WallServerClass
WallServerClass.tagName = "Wall"
WallServerClass.wall = nil
WallServerClass.touchCon  = nil

function WallServerClass.new(wall:Part)
	local self = setmetatable({}, WallServerClass)
	self.wall = wall

    -- self.touchCon = self.wall.Touched:Connect(function(otherPart)
    --     print(otherPart)
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
