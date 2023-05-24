

local colorEnum = {}


colorEnum.ColorName = {
    red = "red",
    orange = "orange",
    yellow = "yellow",
    green = "green",
    cyan = "cyan",
    blue = "blue",
    purple = "purple",
    -- grey = "grey",
    -- white = "white"
}

colorEnum.ColorValue = {
    red = Color3.new(1, 0, 0 ),
    orange = Color3.new(1, 0.533333, 0),
    yellow = Color3.new(1, 0.941176, 0.145098),
    green = Color3.new(0, 1, 0.050980),
    cyan = Color3.new(0, 1, 0.784313),
    blue = Color3.new(0, 0.466666, 1),
    purple = Color3.new(0.968627, 0, 1),
    -- grey = Color3.new(0.619607, 0.619607, 0.619607),
    -- white = Color3.new(1, 1, 1)
}


colorEnum.ColorList = {}
for _, value in colorEnum.ColorName do
    table.insert(colorEnum.ColorList, value)
end


return colorEnum
