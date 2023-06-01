local localPlayer = game.Players.LocalPlayer
local BasePartCls = require(game.StarterPlayer.StarterPlayerScripts.classes.BasePartCls)

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

            task.delay(1, function()
                self.isTouching = false
            end)
        end
    end)

    table.insert(self.connections, con)
end


return TeleportPart
