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
local addHealthEvent = game.ReplicatedStorage.RemoteEvents.addHealthEvent

---- animations ----
local crawAnim = game.ServerStorage.animations.craw
local gunPosAnim = game.ServerStorage.animations.gunPos


local GamePlayerClass = {}
GamePlayerClass.__index = GamePlayerClass
GamePlayerClass.color = nil
GamePlayerClass.skill = nil
GamePlayerClass.paintCan = nil

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

    task.delay(3, function()
        for _, Object in pairs(character:GetChildren()) do
            ChangeGroup(Object)
        end
        print(`  --> Change {self.player.Name} collision group to {groupName}.`)
    end)

end


function GamePlayerClass:SetColor(color)
    local character = self.player.Character
    if not character then
        character = self.player.CharacterAdded:Wait()
    end
    character:WaitForChild("colorString").Value = color

    if color == "empty" then
        self.paintCan.fluid.Transparency = 1
    else
        self.paintCan.fluid.Color = colorValue[color]
        self.paintCan.fluid.Transparency = 0
    end

    local param = argsEnum.changeColorEvent
    param.color = color
    self:NotifyToClient(changeColorEvent, param)
    print(`  --> Change {self.player.Name} color to {color}.`)

end


function GamePlayerClass:InitPlayer()
    local character = self.player.Character
    self:SetCollisionGroup("player")

    local paintCan = game.ServerStorage.paintCan:Clone()
    paintCan.Parent = character
    self.paintCan = paintCan

    character.Humanoid.MaxHealth = universalEnum.maxHealth
    local hp = self:GetOneData(dataKey.hp)
    while not hp do
        hp = self:GetOneData(dataKey.hp)
        print"wait"
        task.wait(0.1)
    end
    character.Humanoid.Health = hp

    CreateModule.CreateValue("StringValue", "colorString", "nil", character)
    CreateModule.CreateValue("BoolValue", "isHiding", false, character)

    local param = argsEnum.changeColorEvent
    param.color = "empty"
    self:NotifyToClient(changeColorEvent, param)

    local animator:Animator = character.Humanoid:WaitForChild("Animator")
    -- local crawTrack = animator:LoadAnimation(crawAnim)
    task.wait(1)
    local gunTrack = animator:LoadAnimation(gunPosAnim)
    gunTrack.Looped = true
    gunTrack.Priority = Enum.AnimationPriority.Movement
    gunTrack:Play()

    local highlight = Instance.new("Highlight")
    highlight.Enabled = false
    highlight.Parent = self.player.Character

end

function GamePlayerClass:OnChatted(message, recipient)
    if message == "/reset data" then
        self:ResetPlayerData()
    elseif string.match(message, "/tool (.+)") then
        local name = string.match(message, "/tool (.+)")
        local tool = game.ServerStorage.tools:FindFirstChild(name)
        if tool then
            self:EquipFakeTool(name)
        else
            warn(`There is no tool named {name}.`)
        end
    elseif message == "/all career" then
        local careerList = self:GetOneData(dataKey.career)
        for i = 1, 5 do
            careerList[i] = true
        end
    end
end

function GamePlayerClass:EquipFakeTool(name)
    local tool:Model = game.ServerStorage.tools:FindFirstChild(name)
    if tool then
        tool = tool:Clone()
    else
        warn(`There is no tool named {name}`)
    end
    tool:PivotTo(self.player.Character.RightHand.CFrame)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = tool.Handle
    weld.Part1 = self.player.Character.RightHand
    weld.Parent = tool.Handle
    tool.Parent = self.player.Character

end

function GamePlayerClass:AddHealth()
    local nowDataHealth = self:GetOneData(dataKey.hp)
    if nowDataHealth < 6 then
        self.player.Character.Humanoid.Health = nowDataHealth + 1
        self:SetOneData(dataKey.hp, math.min(nowDataHealth + 1, universalEnum.maxHealth))
    end
end

return GamePlayerClass
