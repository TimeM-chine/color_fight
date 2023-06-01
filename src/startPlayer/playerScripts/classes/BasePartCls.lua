
---- main ----
local instances = {}


local BasePartCls = {
    part = nil,
    connections = nil,
    folder = nil
}
BasePartCls.__index = BasePartCls


function BasePartCls.new(part:Part, folder)
    local ins = setmetatable({}, BasePartCls)
    ins.part = part
    ins.folder = folder
    ins.connections = {}

    instances[part] = ins
    return ins
end


function BasePartCls:Destroying()
    for part, ins in instances do
        if part == self.part then
            instances[part] = nil
            break
        end
    end

    for _, con in self.connections do
        con:Disconnect()
    end

    for key, value in self do
        self[key] = nil
    end

end


function BasePartCls.GetInsByPart(part)
    return instances[part]
end


return BasePartCls