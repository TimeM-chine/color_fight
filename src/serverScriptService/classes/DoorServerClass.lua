-- ================================================================================
-- door cls --> server side, when player touch, starting counting down and transport
-- ================================================================================


local Door = {}
Door.__index = Door
Door.TAG_NAME = "Door"
Door.OPEN_TIME = 2

function Door.new(door)
	-- Create a table which will act as our new door object.
	local self = {}
	setmetatable(self, Door)
	-- Keep track of some door properties of our own
	self.door = door
	self.debounce = false
	-- Initialize a Touched event to call a method of the door
	self.touchConn = door.Touched:Connect(function(...)
		self:OnTouch(...)
	end)
	-- Initialize the state of the door
	self:SetOpen(false)

	print("Initialized door: " .. door:GetFullName())

	return self
end

function Door:SetOpen(isOpen)
	if isOpen then
		self.door.Transparency = 0.75
		self.door.CanCollide = false
	else
		self.door.Transparency = 0
		self.door.CanCollide = true
	end
end

function Door:OnTouch(part)
	if self.debounce then
		return
	end
	local human = part.Parent:FindFirstChild("Humanoid")
	if not human then
		return
	end
	self.debounce = true
	self:SetOpen(true)
	task.wait(Door.OPEN_TIME)
	self:SetOpen(false)
	self.debounce = false
end

function Door:OnRemoved()
	self.touchConn:disconnect()
	self.touchConn = nil
end

function Door:OnAdded(door)
    return Door.new(door)
end
