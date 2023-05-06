---- ================================================================================
---- collection creation management
---- ================================================================================

---- services ----
local CS = game:GetService("CollectionService")


---- main ----
local CollectionClass = {}
CollectionClass.__index = CollectionClass
CollectionClass.tagName = nil
CollectionClass.addedSignal = nil
CollectionClass.removedSignal = nil
CollectionClass.addedConnections = {}
CollectionClass.removedConnections = {}

function CollectionClass.new(cls)
    local ins = setmetatable({}, CollectionClass)
    ins.tagName = cls.tagName
    ins.addedSignal = CS:GetInstanceAddedSignal(cls.tagName)
    ins.removedSignal = CS:GetInstanceRemovedSignal(cls.tagName)
    ins.addedConnections = {}
    ins.removedConnections = {}
    
    if cls.OnAdded then
        table.insert(ins.addedConnections, ins.addedSignal:Connect(cls.OnAdded))
    end
    if cls.OnRemoved then
        table.insert(ins.removedConnections, ins.removedSignal:Connect(cls.OnRemoved))
    end

    return ins
end


function CollectionClass:BindAddedRecall(recall)
    local con = self.addedSignal:Connect(recall)
    table.insert(self.addedConnections, con)
    return con
end

function CollectionClass:BindRemovedRecall(recall)
    local con = self.removedSignal:Connect(recall)
    table.insert(self.removedConnections, con)
    return con
end


function CollectionClass:DestroyIns()
    for _, con in self.addedConnections do
        con:Disconnect()
    end

    for _, con in self.removedConnections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end

end

return CollectionClass
