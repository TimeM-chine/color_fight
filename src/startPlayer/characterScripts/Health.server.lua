local character = script.Parent

param = OverlapParams.new()
param.FilterDescendantsInstances = workspace.walls:GetDescendants()
param.FilterType = Enum.RaycastFilterType.Include

-- print("playerContact", playerContact)

character:WaitForChild("isHiding")
character:WaitForChild("Highlight")

local function checkHide()
    local cf, size = script.Parent:GetBoundingBox()
    local playerContact = workspace:GetPartBoundsInBox(cf, size, param)
    for _, conPart in playerContact do
        if conPart.colorString.Value == character.colorString.Value then
            return true
        end
    end
    return false
end

while task.wait(0.05) do
    if checkHide() then
        character.isHiding.Value = true
        character.Highlight.Enabled = true
    else
        character.isHiding.Value = false
        character.Highlight.Enabled = false
    end
end

