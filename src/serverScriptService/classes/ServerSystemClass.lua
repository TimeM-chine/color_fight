-- ================================================================================
-- system -> client and server side
-- ================================================================================

---- enum ----
local SystemClass = require(game.ReplicatedStorage.classes.SystemClass)

---- services ----

---- main ----
local ServerSystemClass = setmetatable({}, SystemClass)
ServerSystemClass.__index = ServerSystemClass

function ServerSystemClass.new()
    local self = setmetatable({}, ServerSystemClass)
    self.connections = {}
    return self
end

function ServerSystemClass:ListenForEvent(event:RemoteEvent, recall)
    local signal = event.OnServerEvent:Connect(recall)
    table.insert(self.connections, signal)
    return signal
end

function ServerSystemClass:NotifyToClient(player, event:RemoteEvent, args)
    event:FireClient(player, args)
end

function ServerSystemClass:BroadcastToAllClient(event:RemoteEvent, args)
    event:FireAllClients(args)
end


return ServerSystemClass
