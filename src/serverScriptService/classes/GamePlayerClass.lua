local ServerStorage = game:GetService("ServerStorage")
-- ================================================================================
-- game player cls --> specific game player
-- ================================================================================

---- modules ----


---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorName = colorEnum.ColorName
local colorValue = colorEnum.ColorValue
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local gameConfig = require(game.ReplicatedStorage.configs.GameConfig)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)


---- services ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local changeColorEvent = RemoteEvents.changeColorEvent

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
    character:WaitForChild("paintCan").bottle.SurfaceGui.TextLabel.Text = color
    if color == "empty" then
        character:WaitForChild("Highlight").FillColor = colorEnum.white
        self.paintCan.fluid.Transparency = 1
    elseif color == "white" or color == "black" then
        character:WaitForChild("Highlight").FillColor = colorEnum[color]
        self.paintCan.fluid.Color = colorEnum[color]
        self.paintCan.fluid.Transparency = 0
    else
        character:WaitForChild("Highlight").FillColor = colorValue[color]
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
    local tryTime = 0
    while not hp do
        tryTime += 1
        if tryTime == 11 then
            self.player:Kick()
            return
        end
        task.wait(0.5)
        hp = self:GetOneData(dataKey.hp)
    end
    character.Humanoid.Health = hp

    CreateModule.CreateValue("StringValue", "colorString", "white", character)
    CreateModule.CreateValue("BoolValue", "isHiding", false, character)
    CreateModule.CreateValue("BoolValue", "beforeDeath", false, character)

    local highlight = Instance.new("Highlight")
    highlight.FillColor = colorEnum.white
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.OutlineColor = colorEnum.black
    highlight.FillTransparency = 0.3
    highlight.Parent = character

    local param = argsEnum.changeColorEvent
    param.color = "white"
    self:NotifyToClient(changeColorEvent, param)

    local animator:Animator = character.Humanoid:WaitForChild("Animator")
    -- local crawTrack = animator:LoadAnimation(crawAnim)
    task.wait(1)
    local gunTrack = animator:LoadAnimation(gunPosAnim)
    gunTrack.Looped = true
    gunTrack.Priority = Enum.AnimationPriority.Movement
    gunTrack:Play()

    local tail = Instance.new("Trail")
    tail.Enabled = false
    tail.Lifetime = 0.5
    tail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    tail.Transparency = NumberSequence.new(0)
    tail.Attachment0 = self.player.Character.Head.NeckRigAttachment
    tail.Attachment1 = self.player.Character.LowerTorso.WaistRigAttachment
    tail.Parent = self.player.Character.HumanoidRootPart
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
    elseif message == "/unlock 2" then
        local l = self:GetOneData(dataKey.levelUnlock)
        l[2] = true
    elseif message == '/helmet' then
        local as = game.ServerStorage:FindFirstChild("helmet"):Clone()
        as.Parent = self.player.Character
    elseif message == '/wins' then
        self:UpdatedOneData(dataKey.wins, 2)
        print("now wins", self:GetOneData(dataKey.wins))
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

function GamePlayerClass:TurnOnTopLight()
    local Cone = ServerStorage:FindFirstChild("Cone"):Clone()
    local hrp = self.player.Character.HumanoidRootPart
    Cone.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
    Cone.WeldConstraint.Part0 = Cone
    Cone.WeldConstraint.Part1 = hrp
    Cone.Parent = hrp
end

function GamePlayerClass:TurnOffTopLight()
    local hrp = self.player.Character.HumanoidRootPart
    local cone = hrp:FindFirstChild('Cone')
    if cone then
        cone:Destroy()
    end
end

function GamePlayerClass:EquipTail(ind)
    local tail = self.player.Character.HumanoidRootPart:WaitForChild("Trail")
    if ind then
        tail.Enabled = true
        if gameConfig.tailConfig[ind].type == "color" then
            tail.Color = gameConfig.tailConfig[ind].color
        else
            tail.Texture = TextureIds.tails[ind]
        end
    else
        tail.Enabled = false
    end
end

return GamePlayerClass
