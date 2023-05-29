local BillboardManager = {}

local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local rankListFolder = workspace.rankLists

local config = require(game.ReplicatedStorage.configs.RankList)
local Util = require(game.ReplicatedStorage.modules.Util)

-- cache data of player who is in rank
local rankDataByUserId = {}

local rankTypeList = {
    config.listNames.lv1Time,
    config.listNames.lv1Win,
    config.listNames.lv2Time,
    config.listNames.lv2Win,
}

local rankPageList = {}
local userInfoCache = {}

-- Create rank item
function createRankItem(rank, userId, score, rankType, RankFrame)
		
	local rankFrame = RankFrame:FindFirstChild("Rank"..rank)
	
	if not rankFrame then
		local rankRow = ServerStorage.listUnit
		rankFrame = rankRow:Clone()
		
		rankFrame.Name = "Rank"..rank
		rankFrame.LayoutOrder = rank
		rankFrame.Parent = RankFrame
	end
	
	local rankLabel = rankFrame:WaitForChild("rank")
	rankLabel.Text = "#"..rank
	
	local playerName = rankFrame:WaitForChild("name")
	playerName.Text =  userInfoCache["Player_"..userId]["DisplayName"]
	
	local Counts = rankFrame:WaitForChild("score")
    if string.match(rankType, "Time") then
        Counts.Text = Util.FormatPlayTime(score)
    else
        Counts.Text = Util.FormatNumber(score)
    end
end


function updateLeaderBoard(pages, rankType)

	local topTen = pages:GetCurrentPage()
	local tempRankList = {}
	local RankFrame = nil
    RankFrame = rankListFolder:FindFirstChild(rankType).SurfaceGui.Frame.ScrollingFrame

	local rank = 1

	-- -- update newest data to cache
	-- if not rankDataByUserId[rankType] then
	-- 	rankDataByUserId[rankType] = {}
	-- end

	for i, data in ipairs(topTen) do
		local userId = tonumber(string.match(data.key,".*_(%d+)"))
		local score = data.value
		createRankItem(rank, userId, score, rankType, RankFrame)
		-- tempRankList["Player_"..userId] = playerRankData

		rank = rank + 1

		if rank == 101 then
			break
		end
	end
	
	-- rankDataByUserId[rankType] = tempRankList
	
end

--[[
	Save Player Rank Data
	@param playerUserId 
	@param count player's scrore
	@param db dbname
]]
function BillboardManager.savePlayerRankData(playerUserId, count, db)
	if RunService:IsStudio() then
		return
	end

	if not count then
		return
	end

	if count == 0 then 
		return
	end
	
	-- check if admin
	-- if table.find(GameSetting.AdminIds,playerUserId) then
	-- 	print("admin can't save rank data")
	-- 	return
	-- end

	local playerScope = "Player_" .. playerUserId
	local billboardODS = DataStoreService:GetOrderedDataStore(db)
	local setSuccess,errorMessage = pcall(function()
		billboardODS:SetAsync(playerScope,count)
	end)

	if not setSuccess then
		warn(errorMessage)
	else
		print("save player rank correctly "..db.. " count="..count)
	end
end


function BillboardManager.initBillboard()

	local allPlayerIds = {}

	for _, rankType in ipairs(rankTypeList) do

		local dbName = rankType

		local billboardODS = DataStoreService:GetOrderedDataStore(dbName)
		local setSuccess,pages = pcall(function()
            if string.match(dbName, "Time") then
                return billboardODS:GetSortedAsync(true, config.count)
            else
                return billboardODS:GetSortedAsync(false, config.count)
            end
		end)

		if not setSuccess then
			warn(pages)
		else

			rankPageList[rankType] = pages

			local topTen = pages:GetCurrentPage()
			for rank,data in ipairs(topTen) do
				local userId = tonumber(string.match(data.key,".*_(%d+)"))

				if userInfoCache["Player_"..userId] then 
					continue
				end
				if table.find(allPlayerIds, userId) then
					continue
				end
				table.insert(allPlayerIds, userId)
			end
		end
	end

	local allPlayerIdsGroup = {}
	local groupCount = math.ceil(#allPlayerIds / 100)
	for i = 1, groupCount do
		local startIndex = (i - 1) * 100 + 1
		local endIndex = i * 100
		local group = {}
		for j = startIndex, endIndex do
			if allPlayerIds[j] then
				table.insert(group, allPlayerIds[j])
			end
		end
		table.insert(allPlayerIdsGroup, group)
	end
	
	for _, group in ipairs(allPlayerIdsGroup) do
		local success2,usersInfo = pcall(function()
			return game:GetService("UserService"):GetUserInfosByUserIdsAsync(group)
		end)
		if not success2 then
			warn(usersInfo)
		else
			for _,userInfo in pairs(usersInfo) do
				local userId = userInfo.Id
				userInfoCache["Player_"..userId] = {
					DisplayName = userInfo.DisplayName,
					Username = userInfo.Username,
				}
			end
		end
	end

	-- update all billboard
	for rankType, pageData:Pages in pairs(rankPageList) do
		updateLeaderBoard(pageData, rankType)
	end
	print("update billboard")
end

return BillboardManager
