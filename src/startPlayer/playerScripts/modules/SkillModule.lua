local TextService = game:GetService("TextService")



---- variables ----
local cd = 0
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local skillBtn = PlayerGui.hudScreen.bgFrame.inGame.skillBtn
local cdImg = skillBtn.cdImage
local skillId = skillBtn.skillId.Value
local cdText = cdImg.TextLabel
local co

---- events ----
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local playerHideSkill = game.ReplicatedStorage.RemoteEvents.playerHideSkill

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
        print("player use skill", skillId)
        SkillModule.IntoCd()
        skFun()
    end
end


function SkillModule.SetSkillId(ind)
    skillId = ind
    skillBtn.Visible = true
end


function SkillModule.Sk1()
    -- get the vision of monsters
    workspace.monster.Highlight.Enabled = true
    task.wait(10)
    workspace.monster.Highlight.Enabled = false
end

function SkillModule.Sk2()
    -- hide for few seconds
    playerHideSkill:FireServer()
end

function SkillModule.Sk3()
    LocalPlayer.Character.Humanoid.WalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed * 1.65
    task.wait(3)
    LocalPlayer.Character.Humanoid.WalkSpeed = 16
end

function SkillModule.Sk4()
    -- sight better

    task.wait(3)
end

function SkillModule.Sk5()
    -- platte vision
    for _, platte:Model in workspace.pallets:GetDescendants() do
        if platte:IsA("Model") then
            if (platte.PrimaryPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Magnitude < 10000 then
                platte.Highlight.Enabled = true
            end
        end

    end
    task.wait(3)
    for _, platte:Model in workspace.pallets:GetDescendants() do
        if platte:IsA("Model") then
            platte.Highlight.Enabled = false
        end
    end
end

function runCd()
    cd = 30
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


return SkillModule
