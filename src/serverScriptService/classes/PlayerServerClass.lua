-- ================================================================================
-- player cls --> server side, universal player cls
-- ================================================================================

---- classes ----
local GamePlayerClass = require(script.Parent.GamePlayerClass)

---- modules ----
local DataMgr = require(game.ServerScriptService.modules.DataManager)

---- variables ----
local playerInsList = {}

---- main ----
local PlayerServerClass = setmetatable({}, GamePlayerClass)
PlayerServerClass.__index = PlayerServerClass
PlayerServerClass.player = nil

function PlayerServerClass.new(player:Player)
    local playerIns = setmetatable({}, PlayerServerClass)
    playerIns.player = player
    player.CharacterAdded:Connect(function(character)
        playerIns:InitPlayer()
    end)
    player.Chatted:Connect(function(message, recipient)
        playerIns:OnChatted(message, recipient)
    end)
    table.insert(playerInsList, playerIns)
    return playerIns
end

-- default: create instance
function PlayerServerClass.GetIns(player, createIfNil)
    createIfNil = createIfNil or true

    for _, ins in playerInsList do
        if ins.player == player then
            return ins
        end
    end
    warn(`Didn't find {player.name} ins`)
    if createIfNil then
        print(`  --> Created {player.name} ins`)
        return PlayerServerClass.new(player)
    end
    warn(`Didn't create {player.name} ins`)
end

function PlayerServerClass:SetPos(pos:Vector3)
    self.player.Character:MoveTo(pos)
end

function PlayerServerClass:GetPos()
    return self.player.Character.HumanoidRootPart.CFrame.Position
end

function PlayerServerClass:GetOneData(key)
    return DataMgr:GetPlayerOneData(self.player, key)
end

function PlayerServerClass:SetOneData(key, value)
    return DataMgr:SetPlayerOneData(self.player, key, value)
end

function PlayerServerClass:ResetPlayerData()
    return DataMgr:ResetPlayerData(self.player)
end

function PlayerServerClass:ResetPlayerOneData(key)
    return DataMgr:ResetPlayerOneData(self.player, key)
end


function PlayerServerClass:UpdatedOneData(key, num)
    local oldValue = self:GetOneData(key)
    self:SetOneData(key, oldValue + num)
end

function PlayerServerClass:NotifyToClient(event:RemoteEvent, args)
    event:FireClient(self.player, args)
end

local BadgeService = game:GetService("BadgeService")
function PlayerServerClass:AwardBadge(badgeId)
    local player = self.player
    -- Fetch badge information
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local awardSuccess, result = pcall(function()
				return BadgeService:AwardBadge(player.UserId, badgeId)
			end)

			if not awardSuccess then
				-- the AwardBadge function threw an error
				warn("Error while awarding badge:", result)
			elseif not result then
				-- the AwardBadge function did not award a badge
				warn("Failed to award badge.")
			end
		end
	else
		warn("Error while fetching badge info: " .. badgeInfo)
	end
end

return PlayerServerClass
