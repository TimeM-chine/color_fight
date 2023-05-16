
---- classes ----
local WallServerClass = require(game.ServerScriptService.classes.WallServerClass)
local CollectionCls = require(game.ServerScriptService.classes.CollectionClass)
local BucketModelServerClass = require(game.ServerScriptService.classes.BucketModelServerClass)
local ToolModelServerClass = require(game.ServerScriptService.classes.ToolModelServerClass)

---- services ----
local CS = game:GetService("CollectionService")

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue


---- variables ----

CollectionCls.new(WallServerClass)
CollectionCls.new(BucketModelServerClass)
CollectionCls.new(ToolModelServerClass)

---- random wall color ----
local wallsFolder = workspace.walls

for _, wall:Part in wallsFolder:GetDescendants() do
    if wall:IsA("Folder") then
        continue
    end
    CS:AddTag(wall, WallServerClass.tagName)
end

---- bucket models ----
local bucketModelsFolder = workspace.bucketModels

for _, bucket in bucketModelsFolder:GetChildren() do
    CS:AddTag(bucket, BucketModelServerClass.tagName)
end

---- tool models ----
local toolModelsFolder = workspace.toolModels

for _, toolModel in toolModelsFolder:GetChildren() do
    CS:AddTag(toolModel, ToolModelServerClass.tagName)
end


---- color doors # only color, clients will handle logic ----
local colorDoors = workspace.colorDoors:GetChildren()
for _, door in colorDoors do
    door.Color = colorValue[door.colorString.Value]
end

---- monsters ----
-- local monster = game.ServerStorage.monster
-- local part = workspace.pathPoints:FindFirstChild("Part1")

-- monster:PivotTo(part.CFrame)

-- monster.Parent = workspace

-- local aiScript = game.ServerStorage.monsterAi
-- aiScript:Clone().Parent = monster
