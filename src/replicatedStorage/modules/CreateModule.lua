---- ================================================================================
---- create module
---- ================================================================================

local CreateModule = {}


function CreateModule.CreateValue(insType, name, value, parent)
    local valueIns = Instance.new(insType)
    valueIns.Name = name
    valueIns.Value = value
    valueIns.Parent = parent
end



return CreateModule
