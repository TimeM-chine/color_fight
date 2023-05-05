-- ================================================================================
-- system -> client and server side
-- ================================================================================

---- enum ----
local SystemClass = require(game.ReplicatedStorage.classes.SystemClass)

---- services ----


---- main ----
local ClientSystemClass = setmetatable({}, SystemClass)
ClientSystemClass.__index = ClientSystemClass

function ClientSystemClass.new()
    local self = setmetatable({}, ClientSystemClass)
    self.connections = {}
    return self
end

function ClientSystemClass:ListenForEvent(event:RemoteEvent, recall)
    local signal = event.OnClientEvent:Connect(recall)
    table.insert(self.connections, signal)
    return signal
end

function ClientSystemClass:NotifyToServer(event:RemoteEvent, args)
    event:FireServer(args)
end

return ClientSystemClass
