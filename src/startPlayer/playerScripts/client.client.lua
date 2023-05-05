local StarterGui = game:GetService("StarterGui")


---- modules ----
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)

---- events ----
local testEvent = game.ReplicatedStorage.RemoteEvents.testEvent

---- enums ----
local keyCode = Enum.KeyCode

---- variables ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents



