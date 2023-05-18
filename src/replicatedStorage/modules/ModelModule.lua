-- ================================================================================
-- some functions for Model
-- ================================================================================


local modelModule = {}

function modelModule.SetModelTransparency(model, ratio, whiteList)
    for _, des in model:GetDescendants() do
        if des:IsA("BasePart") then
            des.Transparency = ratio
        end
    end
end

function modelModule.SetModelCollide(model, collide, whiteList)
    for _, des in model:GetDescendants() do
        if des:IsA("BasePart") then
            des.CanCollide = collide
        end
    end
end

return modelModule
