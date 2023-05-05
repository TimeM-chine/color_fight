---- ================================================================================
---- player data manager based on ProfileService
---- ================================================================================

----- modules -----
local ProfileService = require(game.ServerScriptService.libs.ProfileService)
local DefaultValue = require(game.ReplicatedStorage.configs.DefaultValue)

---- remote functions ----
local ClientGetData = game.ReplicatedStorage.remoteFunctions.ClientGetData

----- variables -----
local DEFAULT_DATA = DefaultValue

local Players = game:GetService("Players")
local ProfileStore = ProfileService.GetProfileStore("PlayerData", DEFAULT_DATA)
local profiles = {}


----- main code -----
local DataManager = {}

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	print("PlayerAdded profile ->", profile)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			profiles[player] = profile
			-- A profile has been successfully loaded:
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
end

----- Initialize -----

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

----- Connections -----
Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)

----- APIs -----
function DataManager:GetPlayerAllData(player:Player)
	--print(profiles, player)
    if not profiles[player] then
        warn(`There is no player {player.Name}'s data `)
    end
    return profiles[player]
end

function DataManager:GetPlayerOneData(player, key)
	if typeof(player) == "string" then
		print("You forgot the 'player' param, key is", player)
		return
	end
	local profile = DataManager:GetPlayerAllData(player)
	assert(profile.Data[key], `Can't find key {key} in {player.Name}'s data`)
	return profile.Data[key]
end

function DataManager:ResetPlayerData(player)
	print("reset player data", player.Name)
	profiles[player].Data = DEFAULT_DATA
end

function DataManager:ResetPlayerOneData(player, key)
    print(`reset player {player.Name} key {key}`)
	self:SetPlayerOneData(player, key, DEFAULT_DATA[key])
end

function DataManager:SetPlayerOneData(player, key, value)
	if typeof(player) == "string" then
		warn(`You forgot the 'player' param, key is {player}, value is {key}`)
		return
	end
	local profile = DataManager:GetPlayerAllData(player)
	assert(profile.Data[key], `Can't find key {key} in {player.Name}'s data`)
	assert(type(profile.Data[key]) == type(value), `data types don't match, data:{type(profile.Data[key])}, key:{type(value)} `)
	profile.Data[key] = value
end

function DataManager:AddPlayerOneData(player, key, addValue)
	local nowValue = DataManager:GetPlayerOneData(player, key)
	local newValue = nowValue + addValue
	DataManager:SetPlayerOneData(player, key, newValue)
end

---- offline player ----
function DataManager:SetOfflinePlayerOneData(playerId, key, value)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. playerId)
	if profile then
		profile.Data[key] = value
		profile:Release()
	else
		warn(`[Error] Failed to set offline {playerId} data, id wrong or player is in another server now.`)
	end
end

function DataManager:GetOfflinePlayerOneData(playerId, key)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. playerId)
	if profile then
		local value = profile.Data[key]
		profile:Release()
		return value
	else
		warn(`[Error] Failed to get offline {playerId} data, id wrong or player is in another server now.`)
	end
end

-- for client requesting data
function ClientGetData.OnServerInvoke(player, key)
	return DataManager:GetPlayerOneData(player, key)
end


return DataManager