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
    -- wall.Color = colorValue[colorName]

    CreateModule.CreateValue("StringValue", "colorString", colorName, wall)

    wallInsList[wall] = wallIns
    colorCheck[wall.CFrame.Position] = colorName
end




return WallServerClass
