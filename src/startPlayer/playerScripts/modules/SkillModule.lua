
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
        print("player use skill", skillId)
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
    playerHideSkill:FireServer()
end

function SkillModule.Sk3()
    LocalPlayer.Character.Humanoid.WalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed * 1.65
    task.wait(3)
    LocalPlayer.Character.Humanoid.WalkSpeed = universalEnum.normalSpeed
end

function SkillModule.Sk4()
    -- sight better
    -- notifyEvent:Fire()
    task.wait(3)
end

function SkillModule.Sk5()
    -- platte vision
    local ind = BindableFunctions.getLevelInd:Invoke()
    local lightPlatte = {}
    for _, platte:Model in workspace.pallets["level"..ind]:GetChildren() do
        if platte:IsA("Model") then
            if platte.PrimaryPart.CFrame.Position.Y > -100 then
                platte.Highlight.Enabled = true
                table.insert(lightPlatte, platte)
            end
        end
    end
    task.wait(10)
    for _, platte:Model in lightPlatte do
        platte.Highlight.Enabled = false
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
