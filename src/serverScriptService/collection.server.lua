
---- classes ----
local WallServerClass = require(game.ServerScriptService.classes.WallServerClass)
local CollectionCls = require(game.ServerScriptService.classes.CollectionClass)
local BucketModelServerClass = require(game.ServerScriptService.classes.BucketModelServerClass)
local ToolModelServerClass = require(game.ServerScriptService.classes.ToolModelServerClass)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- services ----
local CS = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local BillboardManager = require(game.ServerScriptService.modules.BillboardManager)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local rankListConfig = require(game.ReplicatedStorage.configs.RankList)

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents
local teleportBindEvent = game.ReplicatedStorage.BindableEvents.teleportBindEvent

---- variables ----
local playerStartTime = {}


teleportBindEvent.Event:Connect(function(player, levelInd)
    if not playerStartTime[player] then
        playerStartTime[player] = {}
    end
    playerStartTime[player][levelInd] = os.time()
end)


CollectionCls.new(WallServerClass)
CollectionCls.new(BucketModelServerClass)
CollectionCls.new(ToolModelServerClass)

---- random wall color ----
local wallsFolder = workspace.walls

for _, wall:Part in wallsFolder:GetDescendants() do
    if wall:IsA("Part") then
        CS:AddTag(wall, WallServerClass.tagName)
    end
end

---- bucket models ----
local bucketModelsFolder = workspace.bucketModels

for _, bucket in bucketModelsFolder.level1:GetChildren() do
    CS:AddTag(bucket, BucketModelServerClass.tagName)
end

for _, bucket in bucketModelsFolder.level2:GetChildren() do
    CS:AddTag(bucket, BucketModelServerClass.tagName)
end


---- tool models ----
local toolModelsFolder = workspace.toolModels

for _, toolModel in toolModelsFolder:GetChildren() do
    CS:AddTag(toolModel, ToolModelServerClass.tagName)
end


---- color doors # only color, clients will handle logic ----
local colorDoors = workspace.colorDoors:GetDescendants()
for _, door in colorDoors do
    if door:IsA("Part") then
        door.SurfaceGui.color.Text = door.colorString.Value
        door.SurfaceGui.color.TextColor3 = colorValue[door.colorString.Value]
        door.SurfaceGui.TextLabel.TextColor3 = colorValue[door.colorString.Value]
    end
end

---- keys
for _, key:Part in workspace.keys:GetChildren() do
    key.ProximityPrompt.Triggered:Connect(function(player:Player)
        remoteEvents.hideBucketEvent:FireClient(player, key)  -- same logic with buckets
        -- local tool = ServerStorage.keys:FindFirstChild(key.Name)
        -- if tool then
        --     tool = tool:Clone()
        --     tool.Parent = player.Character
        -- end

        remoteEvents.serverNotifyEvent:FireClient(player, "You win in this level!")
        player.Character:PivotTo(workspace.mainCityLocation.CFrame + Vector3.new(0, 5, 0))
	    remoteEvents.teleportEvent:FireClient(player, 0)

        local playerIns = PlayerServerClass.GetIns(player)
        if key.Name == "level1Key" then
            playerIns:UpdatedOneData(dataKey.lv1Wins, 1)
            local lv1Time = os.time() - playerStartTime[player][1]
            if lv1Time < playerIns:GetOneData(dataKey.lv1Time) then
                playerIns:SetOneData(dataKey.lv1Time, lv1Time)
                BillboardManager.savePlayerRankData(player.UserId, playerIns:GetOneData(dataKey.lv1Time), rankListConfig.listNames.lv1Time)
            end

            BillboardManager.savePlayerRankData(player.UserId, playerIns:GetOneData(dataKey.lv1Wins), rankListConfig.listNames.lv1Win)
        else
            playerIns:UpdatedOneData(dataKey.lv2Wins, 1)
            local lv2Time = os.time() - playerStartTime[player][2]
            if lv2Time < playerIns:GetOneData(dataKey.lv2Time) then
                playerIns:SetOneData(dataKey.lv2Time, lv2Time)
                BillboardManager.savePlayerRankData(player.UserId, playerIns:GetOneData(dataKey.lv2Time), rankListConfig.listNames.lv2Time)
            end

            BillboardManager.savePlayerRankData(player.UserId, playerIns:GetOneData(dataKey.lv2Wins), rankListConfig.listNames.lv2Win)
        end
        playerIns:UpdatedOneData(dataKey.wins, 1)
        playerIns:UpdatedOneData(dataKey.totalWins, 1)
        player.leaderstats.Wins.Value = playerIns:GetOneData(dataKey.totalWins)
        player.leaderstats.NowWins.Value = playerIns:GetOneData(dataKey.wins)
    end)
end

---- monsters ----
local monsters = game.ServerStorage.monsters

for _, monster in monsters:GetChildren() do
    -- if monster.Name ~= "monster3" then continue end
    local part = workspace.pathPoints:FindFirstChild(monster.Name):FindFirstChild("Part1")
    monster:PivotTo(part.CFrame)
    monster.Parent = workspace

    local aiScript = game.ServerStorage.monsterAi
    aiScript:Clone().Parent = monster
end

