
---- services ----
local Debris = game:GetService"Debris"

---- variables ----
local cd = 0
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local skillBtn:ImageButton = PlayerGui.hudScreen.bgFrame.inGame.skillBtn
local cdImg = skillBtn.cdImage
local skillId = skillBtn.skillId.Value
local cdText = cdImg.TextLabel
local co

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local playerHideSkill = game.ReplicatedStorage.RemoteEvents.playerHideSkill
local BindableFunctions = game.ReplicatedStorage.BindableFunctions
local chooseSkillEvent = game.ReplicatedStorage.RemoteEvents.chooseSkillEvent

---- modules ----
local playerModule = require(script.Parent.PlayerClientModule)

---- enums ----
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)

local SkillModule = {}

function SkillModule.UseSkill()
    if skillId == 0 then
        print("skill id is 0")
        return
    end
    if cd > 0 then
        notifyEvent:Fire("Skill is in CD.")
    else
        local skFun = SkillModule["Sk"..skillId]
        SkillModule.IntoCd()
        skFun()
    end
end


function SkillModule.SetSkillId(ind)
    chooseSkillEvent:FireServer(ind)
    if ind == 0 then
        return
    end
    skillBtn.Image = TextureIds.skillImg[ind][1]
    skillBtn.PressedImage = TextureIds.skillImg[ind][2]
    skillId = ind
    skillBtn.Visible = true
end


function SkillModule.Sk1()
    -- get the vision of monsters
    local ind = BindableFunctions.getLevelInd:Invoke()
    notifyEvent:Fire("Now you can see the monster's outline.")
    if ind == 1 then
        workspace.monster1.Highlight.Enabled = true
        task.wait(10)
        workspace.monster1.Highlight.Enabled = false
    else
        workspace.monster2.Highlight.Enabled = true
        workspace.monster3.Highlight.Enabled = true
        workspace.monster4.Highlight.Enabled = true
        task.wait(10)
        workspace.monster2.Highlight.Enabled = false
        workspace.monster3.Highlight.Enabled = false
        workspace.monster4.Highlight.Enabled = false
    end

end

function SkillModule.Sk2()
    -- hide for few seconds
    notifyEvent:Fire("You will hide for few seconds.")
    playerHideSkill:FireServer()
end

function SkillModule.Sk3()
    notifyEvent:Fire("You will speed up for few seconds.")

    LocalPlayer.Character.Humanoid.WalkSpeed = playerModule.GetPlayerSpeed() * 1.65
    task.wait(10)
    LocalPlayer.Character.Humanoid.WalkSpeed = playerModule.GetPlayerSpeed()
end

function SkillModule.Sk4()
    notifyEvent:Fire("Your vision will be larger for few seconds.")

    game.Lighting.Atmosphere.Density = 0.6
    task.wait(20)
    game.Lighting.Atmosphere.Density = 0.8
end

function SkillModule.Sk5()
    notifyEvent:Fire("Now you can see pallets' outline.")

    -- platte vision
    local ind = BindableFunctions.getLevelInd:Invoke()
    for _, platte:Model in workspace.pallets["level"..ind]:GetChildren() do
        if platte:IsA("Model") then
            if platte.PrimaryPart.CFrame.Position.Y > -100 then
                local hl = Instance.new("Highlight")
                hl.Parent = platte
                Debris:AddItem(hl, 10)
            end
        end
    end
end

function runCd()
    if cd == 0 then
        cd = 45
    end
    while cd >= 1 do
        -- print("cd", cd)
        cd -= 1
        cdImg.TextLabel.Text = tostring(cd)
        if cd == 0 then
            cdImg.Visible = false
        end
        task.wait(1)
    end
end

function SkillModule.IntoCd()
    cdImg.Visible = true
    co = coroutine.create(runCd)
    coroutine.resume(co)
end


function SkillModule.SetCd(num)
    cd = num
end

function SkillModule.GetCd()
    return cd
end


return SkillModule
