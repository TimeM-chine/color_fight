-- ================================================================================
-- system -> client and server side
-- ================================================================================

---- enum ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)

---- services ----
local RS = game:GetService"RunService"
local isServer = RS:IsServer()

---- main ----
local SystemClass = {}
SystemClass.__index = SystemClass
SystemClass.connections = {}

function SystemClass:Shutdown()
    for _, signal:RBXScriptConnection in self.connections do
        signal:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
    self[{}] = nil

end


return SystemClass
