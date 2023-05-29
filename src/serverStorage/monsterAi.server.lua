local ServerStorage = game:GetService("ServerStorage")

---- services ----
local Debris = game:GetService"Debris"

---- modules -----
local SimplePath = require(game.ServerScriptService.modules.SimplePath)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)

---- variables ----
local agent:Model = script.Parent
local target, lastHurtPlayer, lastPointPart
local pointsFolder = workspace.pathPoints:FindFirstChild(agent.Name)
local pointsNum = #pointsFolder:GetChildren()
local myHRP = agent:WaitForChild("HumanoidRootPart")
local myH = agent:WaitForChild("Humanoid")
local cor = nil
local walkAnim = agent.Animation
local animator:Animator = myH.Animator
local aniTrack = animator:LoadAnimation(walkAnim)
local playerTargetTime = {}
local footprint:Part = ServerStorage.footprint
local monsterSound:Sound = game.SoundService.monster:Clone()
local targetTraceTime = 0

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- main ----
aniTrack:Play()
monsterSound.Parent = agent.HumanoidRootPart
monsterSound:Play()

local pathParam = table.clone(argsEnum.CreatePath)
pathParam.AgentCanClimb = false
pathParam.AgentCanJump = false
pathParam.AgentRadius = 1
pathParam.AgentHeight = 8
pathParam.WaypointSpacing = 5
-- local spParam = table.clone(argsEnum.SimplePath)
-- spParam.TIME_VARIANCE = 0.3
-- spParam.JUMP_WHEN_STUCK = false
-- local path = SimplePath.new(agent, pathParam, spParam)
local path = SimplePath.new(agent, pathParam)

local function GetNextPoint()
    if not lastPointPart then
        return pointsFolder:FindFirstChild("Part1")
    end
    -- print(lastPointPart)
    if (myHRP.CFrame.Position - lastPointPart.CFrame.Position).Magnitude <= 10 then
        local lastInd = string.match(lastPointPart.Name, "Part(%d+)")
        -- print(lastPointPart, pointsFolder:FindFirstChild("Part"..(lastInd % pointsNum + 1)))
        return pointsFolder:FindFirstChild("Part"..(lastInd % pointsNum + 1))
    end
    return lastPointPart
end

function HurtPlayer(player)
    if not player.Character.isHiding.Value then
        local human:Humanoid = player.Character.Humanoid
        -- if human.Health > 1 then
        human:TakeDamage(1)
        print(`hurt {player}, last player {lastHurtPlayer}`)
        -- else
        --     player.Character.beforeDeath.Value = true
        --     remoteEvents.beforeDeathEvent:FireClient(player)
        -- end
        PlayerServerClass.GetIns(player):SetOneData(dataKey.hp, math.max(1, human.Health))
    end
    SetLastHurtPlayer(player)
end

function SetLastHurtPlayer(player)
    if cor then
        coroutine.close(cor)
    end
    lastHurtPlayer = player

    cor = coroutine.create(function()
        task.wait(6)
        lastHurtPlayer = nil
    end)
    coroutine.resume(cor)

end

local function GetNearestCharacterAndDist()
    local fromPosition = myHRP.CFrame.Position
    local character, dist = nil, math.huge
	for _, player in ipairs(game.Players:GetPlayers()) do
        if player == lastHurtPlayer then
            continue
        end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("isHiding") then continue end
        if not player.Character:FindFirstChild("beforeDeath") then continue end
        -- print(player.Character.beforeDeath.Value, lastHurtPlayer)
        if player.Character.beforeDeath.Value then continue end

        local playerDis = (player.Character.PrimaryPart.Position - fromPosition).Magnitude
		if playerDis < dist then
            if playerDis <= 10 then
                HurtPlayer(player)
            end
			character, dist = player.Character, playerDis
		end
	end
	return character, dist
end


local function GetNextTarget()
    local character, dist = GetNearestCharacterAndDist()
    if character and character.HumanoidRootPart and dist <= 50 then
        if lastHurtPlayer then
            lastPointPart = GetNextPoint()
            return lastPointPart, false
        end
        local player = game.Players:GetPlayerFromCharacter(character)
        if playerTargetTime[player] then
            playerTargetTime[player] += 1
        else
            playerTargetTime[player] = 1
        end
        -- print(playerTargetTime[player])
        if playerTargetTime[player] >= 15 then
            SetLastHurtPlayer(player)
            playerTargetTime[player] = 0
        end
        return character.HumanoidRootPart, true
    end

    lastPointPart = GetNextPoint()
    return lastPointPart, false
end


-- path.Visualize = true

-- path.Blocked:Connect(function(...)
--     print("blocked", ...)
-- end)

-- path.Reached:Connect(function(...)
--     print("reached", ...)
-- end)

while task.wait(0.1) do
    local nextTarget, isPlayer  = GetNextTarget()
    -- print(`{agent.Name} nextTarget: {nextTarget}`)
    if agent.Name ~= "monster4" then
        local footCopy = footprint:Clone()
        footCopy.CFrame = agent.RightFoot.CFrame
        footCopy.SurfaceGui.ImageLabel.Image = TextureIds.footprint[math.random(1, #TextureIds.footprint)]
        footCopy.Parent = workspace
        Debris:AddItem(footCopy, 5)

        footCopy = footprint:Clone()
        footCopy.CFrame = agent.LeftFoot.CFrame
        footCopy.SurfaceGui.ImageLabel.Image = TextureIds.footprint[math.random(1, #TextureIds.footprint)]
        footCopy.Parent = workspace
        Debris:AddItem(footCopy, 5)
    end

    if (not path:Run(nextTarget)) and (not isPlayer) then
        targetTraceTime += 1
        if targetTraceTime >= 30 then
            agent:PivotTo(nextTarget.CFrame)
            targetTraceTime = 0
        end
    else
        targetTraceTime = 0
    end
end


