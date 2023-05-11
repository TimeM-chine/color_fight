
---- classes ----
local WallServerClass = require(game.ServerScriptService.classes.WallServerClass)
local CollectionCls = require(game.ServerScriptService.classes.CollectionClass)
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
CollectionCls.new(ToolModelServerClass)

---- random wall color ----
local wallsFolder = workspace.walls

for _, wall:Part in wallsFolder:GetChildren() do
    CS:AddTag(wall, WallServerClass.tagName)
end


---- tool models ----
local toolModelsFolder = workspace.toolModels
local modelTab = toolModelsFolder:GetChildren()

for i=1, 7 do
    local colorName = colorList[i]
    local toolModel = modelTab[i]
    toolModel.Color = colorValue[colorName]
    CreateModule.CreateValue("StringValue", "colorString", colorName, toolModel)

    CS:AddTag(toolModel, ToolModelServerClass.tagName)
end


---- doors -----
local doorsFolder = workspace.colorDoors
local doorTable = doorsFolder:GetChildren()

for i=1, 7 do
    local colorName = colorList[i]
    local toolModel = doorTable[i]
    toolModel.Color = colorValue[colorName]
    CreateModule.CreateValue("StringValue", "colorString", colorName, toolModel)
end


---- monsters ----
-- local monster = game.ServerStorage.monster
-- local part = workspace.pathPoints:FindFirstChild("Part1")

-- monster:MoveTo(part.CFrame.Position)

-- monster.Parent = workspace

-- local aiScript = game.ServerStorage.monsterAi
-- aiScript:Clone().Parent = monster
