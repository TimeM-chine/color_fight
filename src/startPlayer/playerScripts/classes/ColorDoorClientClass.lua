-- ================================================================================
-- system -> client and server side
-- ================================================================================

---- enum ----

---- services ----

---- variables ----
local localPlayer = game.Players.LocalPlayer
local doorFolder = workspace.colorDoors

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent

---- main ----
local ColorDoorClientClass = {}
ColorDoorClientClass.__index = ColorDoorClientClass
ColorDoorClientClass.door = nil
ColorDoorClientClass.clickCon = nil
ColorDoorClientClass.totalClick = 5
ColorDoorClientClass.remainClick = ColorDoorClientClass.totalClick

function ColorDoorClientClass.new(door)
    local self = setmetatable({}, ColorDoorClientClass)
    self.door = door

    self.door.ClickDetector.MouseClick:Connect(function()
        self:Clicked()
    end)

    localPlayer.CharacterAdded:Connect(function(character)
        self:SetVisible(true)
    end)

    return self
end

function ColorDoorClientClass:Clicked()
    if self:CheckCondition() then
        self.remainClick -= 1
        self.door.SurfaceGui.TextLabel.Text = self.remainClick
        self.door.Transparency = (self.totalClick - self.remainClick)/self.totalClick
        if self.remainClick <= 0 then
            -- self.door:Destroy()
            self:SetVisible(false)
            changeColorEvent:FireServer("empty")
        end

        if #doorFolder:GetChildren() == 0 then
            notifyEvent:Fire("You Win!")
        end
    else
        notifyEvent:Fire("not right color")
    end

end


function ColorDoorClientClass:SetVisible(flag)
    if flag then
        self.door.Transparency = 0
        self.door.ClickDetector.MaxActivationDistance = 30
        self.door.SurfaceGui.TextLabel.Text = "5"
    else
        self.door.Transparency = 1
        self.door.ClickDetector.MaxActivationDistance = 0
        self.door.SurfaceGui.TextLabel.Text = ""
    end
    self.door.CanCollide = flag
end

function ColorDoorClientClass:CheckCondition()
    local color = localPlayer.Character.colorString.Value

    return color == self.door.colorString.Value
end


return ColorDoorClientClass