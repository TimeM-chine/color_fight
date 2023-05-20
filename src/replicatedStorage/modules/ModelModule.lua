-- ================================================================================
-- some functions for Model
-- ================================================================================


local modelModule = {}

function modelModule.SetModelTransparency(model, ratio, whiteList)
    whiteList = whiteList or {}
    for _, des in model:GetDescendants() do
        if des:IsA("BasePart") and not table.find(whiteList, des) then
            des.Transparency = ratio
        end
    end
end

function modelModule.SetModelCollide(model, collide, whiteList)
    whiteList = whiteList or {}
    for _, des in model:GetDescendants() do
        if des:IsA("BasePart") and not not table.find(whiteList, des) then
            des.CanCollide = collide
        end
    end
end

return modelModule
