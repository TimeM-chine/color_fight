-- ================================================================================
-- door cls --> server side, when player touch, starting counting down and transport
-- ================================================================================


---- variables ----
local wallInsList = {}


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

    for key, _ in wallInsList[wall] do
        wallInsList[wall][key] = nil
    end
    wallInsList[wall] = nil
end

function WallServerClass.OnAdded(wall:Part)
    local wallIns = WallServerClass.new(wall)
    
    wallInsList[wall] = wallIns
end


return WallServerClass
