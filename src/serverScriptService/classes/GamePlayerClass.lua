-- ================================================================================
-- game player cls --> specific game player
-- ================================================================================

---- enums ----
local colorName = require(game.ReplicatedStorage.enums.colorEnum).ColorName
local colorValue = require(game.ReplicatedStorage.enums.colorEnum).ColorValue
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)

---- services ----

---- events ----
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent



local GamePlayerClass = {}
GamePlayerClass.__index = GamePlayerClass
GamePlayerClass.color = nil
GamePlayerClass.skill = nil

function GamePlayerClass:SetCollisionGroup(groupName)
    local function ChangeGroup(Part)
        if Part:IsA("BasePart") then
            Part.CollisionGroup = groupName
        end
    end
    
    local character = self.player.Character
    if not character then
        character = self.player.CharacterAdded:Wait()
    end
    -- character.ChildAdded:Connect(ChangeGroup)
    for _, Object in pairs(character:GetChildren()) do
        ChangeGroup(Object)
    end

    print(`  --> Change {self.player.Name} collision group to {groupName}.`)
end


function GamePlayerClass:SetColor(color)
    local character = self.player.Character
    if not character then
        character = self.player.CharacterAdded:Wait()
    end

    local param = argsEnum.changeColorEvent
    param.color = color
    self:NotifyToClient(changeColorEvent, param)
    print(`  --> Change {self.player.Name} color to {color}.`)

end




return GamePlayerClass
