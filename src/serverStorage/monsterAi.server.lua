
---- modules -----
local SimplePath = require(game.ServerScriptService.modules.SimplePath)

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)

---- variables ----
local agent:Model = script.Parent
local target, lastHurtPlayer, lastPointPart
local pointsFolder = workspace.pathPoints
local myHRP = agent:WaitForChild("HumanoidRootPart")
local myH = agent:WaitForChild("Humanoid")
local cor = nil
local walkAnim = agent.Animation
local animator:Animator = myH.Animator
local aniTrack = animator:LoadAnimation(walkAnim)
local playerTargetTime = {}

---- main ----
aniTrack:Play()

local pathParam = table.clone(argsEnum.CreatePath)
pathParam.AgentCanClimb = false
pathParam.AgentCanJump = false

-- local spParam = table.clone(argsEnum.SimplePath)
-- spParam.TIME_VARIANCE = 0.3
-- spParam.JUMP_WHEN_STUCK = false
-- local path = SimplePath.new(agent, pathParam, spParam)
local path = SimplePath.new(agent, pathParam)

local function GetNextPoint()
    if not lastPointPart then
        return pointsFolder:FindFirstChild("Part1")
    end

    if (myHRP.CFrame.Position - lastPointPart.CFrame.Position).Magnitude <= 3 then
        local lastInd = string.match(lastPointPart.Name, "Part(%d+)")
        return pointsFolder:FindFirstChild("Part"..(lastInd % 19 + 1))
    end

    return lastPointPart
end

function HurtPlayer(player)
    if not player.character.isHiding.Value then
        local human:Humanoid = player.character.Humanoid
        human:TakeDamage(1)
    end
    SetLastHurtPlayer(player)
end

function SetLastHurtPlayer(player)
    if cor then
        coroutine.close(cor)
    end
    lastHurtPlayer = player

    cor = coroutine.create(function()
        task.wait(8)
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

        local playerDis = (player.Character.PrimaryPart.Position - fromPosition).Magnitude
		if playerDis < dist then
            if playerDis <= 15 then
                HurtPlayer(player)
            end
			character, dist = player.Character, playerDis
		end
	end
	return character, dist
end


local function GetNextTarget()
    local character, dist = GetNearestCharacterAndDist()
    if character and character.HumanoidRootPart and dist <= 150 then
        local player = game.Players:GetPlayerFromCharacter(character)
        if playerTargetTime[player] then
            playerTargetTime[player] += 1
        else
            playerTargetTime[player] = 1
        end
        -- print(playerTargetTime[player])
        if playerTargetTime[player] >= 20 then
            SetLastHurtPlayer(player)
            playerTargetTime[player] = 0
        end
        return character.HumanoidRootPart
    end

    lastPointPart = GetNextPoint()
    return lastPointPart
end


path.Visualize = true

-- path.Blocked:Connect(function(...)
--     print("blocked", ...)
-- end)

-- path.Reached:Connect(function(...)
--     print("reached", ...)
-- end)

while task.wait(0.5) do
    local nextTarget = GetNextTarget()
    -- print("next target", nextTarget)

    path:Run(nextTarget)
    
end


