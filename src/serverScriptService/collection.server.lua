
---- classes ----
local WallServerClass = require(game.ServerScriptService.classes.WallServerClass)
local CollectionCls = require(game.ServerScriptService.classes.CollectionClass)

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



---- random wall color ----
local wallsFolder = workspace.walls

for _, wall:Part in wallsFolder:GetChildren() do
    local colorName = colorList[math.random(1, 7)]
    wall.Color = colorValue[colorName]

    CreateModule.CreateValue("StringValue", "colorString", colorName, wall)
    CS:AddTag(wall, WallServerClass.tagName)
end


