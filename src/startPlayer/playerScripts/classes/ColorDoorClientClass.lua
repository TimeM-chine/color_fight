-- ================================================================================
-- system -> client and server side
-- ================================================================================

---- enum ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)

---- services ----

---- variables ----
local localPlayer = game.Players.LocalPlayer
local doorFolder = workspace.colorDoors

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent
local perTipEvent = game.ReplicatedStorage.BindableEvents.perTipEvent
local BindableEvents = game.ReplicatedStorage.BindableEvents

---- functions ----
local BindableFunctions = game.ReplicatedStorage.BindableFunctions

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

    BindableEvents.resetLevelEvent.Event:Connect(function()
        self:SetVisible(true)
    end)

    game.SoundService.paint:Clone().Parent = self.door

    return self
end

function ColorDoorClientClass:Clicked()
    if self:CheckCondition() then
        self.remainClick -= 1
        self.door.Transparency = (self.totalClick - self.remainClick)/self.totalClick
        local wallImg:ImageLabel = self.door.SurfaceGui.ImageLabel
        wallImg.Visible = true
        wallImg.Image = TextureIds.wallPaints[self.door.colorString.Value.."Paint"..(5 - self.remainClick)]
        if self.remainClick <= 0 then
            -- self.door:Destroy()
            local levelInd = BindableFunctions.getLevelInd:Invoke()
            if self.door.colorString.Value == colorEnum.ColorName.blue and levelInd == 2 then
                self.door.brother.Value.Transparency = 1
                self.door.brother.Value.ClickDetector.MaxActivationDistance = 0
                self.door.brother.Value.SurfaceGui.TextLabel.Text = ""
                self.door.brother.Value.CanCollide = false
            elseif self.door.colorString.Value == colorEnum.ColorName.purple then
                perTipEvent:Fire()
                notifyEvent:Fire("Now you can't hide behind the purple wall", "bottom")
            end
            
            self:SetVisible(false)
            changeColorEvent:FireServer("empty")
        end
        self.door.paint:Play()
    else
        notifyEvent:Fire("not right color")
    end

end


function ColorDoorClientClass:SetVisible(flag)
    if flag then
        self.door.Transparency = 0.35
        self.door.SurfaceGui.Enabled = true
        self.door.ClickDetector.MaxActivationDistance = 30
        self.door.SurfaceGui.ImageLabel.Visible = false
        self.remainClick = self.totalClick
    else
        self.door.Transparency = 1
        self.door.SurfaceGui.Enabled = false
        self.door.ClickDetector.MaxActivationDistance = 0
        -- self.door.SurfaceGui.TextLabel.Text = ""
    end
    self.door.CanCollide = flag
end

function ColorDoorClientClass:CheckCondition()
    local color = localPlayer.Character.colorString.Value

    return color == self.door.colorString.Value
end


return ColorDoorClientClass
