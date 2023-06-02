local character = script.Parent

local filter = {}

for _, child in workspace.walls:GetChildren() do
    table.insert(filter, child.wall)
end


for _, part in workspace.safeAreas:GetChildren() do
    table.insert(filter, part)
end

param = OverlapParams.new()
param.FilterDescendantsInstances = filter
param.FilterType = Enum.RaycastFilterType.Include

-- print("playerContact", playerContact)

character:WaitForChild("isHiding")
-- character:WaitForChild("Highlight")

local function checkHide()
    local cf, size = script.Parent:GetBoundingBox()
    local playerContact = workspace:GetPartBoundsInBox(cf, size, param)
    for _, conPart in playerContact do
        if conPart.Parent.Name == "safeAreas" then
            return true
        end
        if conPart.colorString.Value == character.colorString.Value then
            return true
        end
    end
    return false
end

while task.wait(0.05) do
    if checkHide() then
        character.isHiding.Value = true
        -- character.Highlight.Enabled = true
    else
        character.isHiding.Value = false
        -- character.Highlight.Enabled = false
    end
end

