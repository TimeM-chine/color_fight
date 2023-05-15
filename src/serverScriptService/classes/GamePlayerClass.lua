-- ================================================================================
-- game player cls --> specific game player
-- ================================================================================

---- modules ----


---- enums ----
local colorName = require(game.ReplicatedStorage.enums.colorEnum).ColorName
local colorValue = require(game.ReplicatedStorage.enums.colorEnum).ColorValue
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

---- services ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

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
    task.wait(3)
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

    character.colorString.Value = color

    local param = argsEnum.changeColorEvent
    param.color = color
    self:NotifyToClient(changeColorEvent, param)
    print(`  --> Change {self.player.Name} color to {color}.`)

end


function GamePlayerClass:InitPlayer()
    local character = self.player.Character
    self:SetCollisionGroup("player")
    -- if not character then
    --     character = self.player.CharacterAdded:Wait()
    -- end
    character.Humanoid.MaxHealth = 1
    character.Humanoid.Health = 1
    CreateModule.CreateValue("StringValue", "colorString", "nil", character)
    CreateModule.CreateValue("BoolValue", "isHiding", false, character)

    local param = argsEnum.changeColorEvent
    param.color = "empty"
    self:NotifyToClient(changeColorEvent, param)
end


return GamePlayerClass
