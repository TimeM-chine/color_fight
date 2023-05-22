
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

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- variables ----

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
    key.ProximityPrompt.Triggered:Connect(function(player)
        remoteEvents.hideBucketEvent:FireClient(player, key)  -- same logic with buckets
        local tool = ServerStorage.keys:FindFirstChild(key.Name)
        if tool then
            tool = tool:Clone()
            tool.Parent = player.Character
        end
        if key.Name == "level1Key" then
            remoteEvents.serverNotifyEvent:FireServer(player, "Get back to lobby to unlock level 2.")
        else
            remoteEvents.serverNotifyEvent:FireServer(player, "Get back to lobby to get wins.")
        end
        PlayerServerClass.GetIns(player):UpdatedOneData(dataKey.wins, 1)
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

