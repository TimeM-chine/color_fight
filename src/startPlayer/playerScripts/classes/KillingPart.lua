local localPlayer = game.Players.LocalPlayer
local Replicated = game:GetService("ReplicatedStorage")
local BasePartCls = require(game.StarterPlayer.StarterPlayerScripts.classes.BasePartCls)
local Stitches = require(Replicated.Stitches)

local BaseSystem = require(Replicated.Systems.BaseSystem)
Stitches.Start()

---- main ----
local KillingPart = setmetatable({
    damage = 1,
    isTouching = false,
}, BasePartCls)
KillingPart.__index = KillingPart


function KillingPart.new(part:Part)
    local ins = setmetatable(getmetatable(KillingPart).new(part, part.KillingPart), KillingPart)
    ins.damage = ins.folder.damage.Value

    ins:Init()
    return ins
end

function KillingPart:Init()
    local con = self.part.Touched:Connect(function(otherPart)
        if self.isTouching then return end
        if otherPart:IsDescendantOf(localPlayer.Character) then
            self.isTouching = true
            ---- damage player
            BaseSystem.Hurt(self.damage)
            task.delay(2, function()
                self.isTouching = false
            end)
        end
    end)

    table.insert(self.connections, con)
end

return KillingPart