-- ================================================================================
-- ui controller
-- ================================================================================


---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local pushScreenGui = PlayerGui.pushScreen
local hudScreenGui = PlayerGui.hudScreen

---- main ----
local controller = {}

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local tweenArgs = table.clone(argsEnum.TweenArgs)

-- close shut dawn hud, and only show the screen
function controller.PushScreen(screenName)
    pushScreenGui.bgFrame:ClearAllChildren()
    local screenIns = PlayerGui.screens:FindFirstChild(screenName)
    if not screenIns then
        warn(`There is no screen named {screenName}`)
        return
    end

    screenIns:Clone().Parent = pushScreenGui.bgFrame
    hudScreenGui.Enabled = false
    pushScreenGui.Enabled = true

    controller.ShowBySize(pushScreenGui.bgFrame)
end

-- pop screen
function controller.PopScreen()
    controller.CloseBySize(pushScreenGui.bgFrame)
    pushScreenGui.bgFrame:ClearAllChildren()
    hudScreenGui.Enabled = true
    pushScreenGui.Enabled = false
end

-- scale show
function controller.ShowBySize(comp, args)
    comp.Visible = true

    local param = tweenArgs
    if args then
        param.easingDir = args.easingDir or tweenArgs.easingDir
        param.easingStyle = args.easingStyle or tweenArgs.easingStyle
        param.tweenTime = args.tweenTime or tweenArgs.tweenTime
    end

    comp:TweenSize(UDim2.new(1, 0, 1, 0), param.easingDir, param.easingStyle, param.tweenTime)
end

-- scale show
function controller.CloseBySize(comp, args)
    local param = tweenArgs
    if args then
        param.easingDir = args.easingDir or tweenArgs.easingDir
        param.easingStyle = args.easingStyle or tweenArgs.easingStyle
        param.tweenTime = args.tweenTime or tweenArgs.tweenTime
    end
    comp:TweenSize(UDim2.new(0, 0, 0, 0), param.easingDir, param.easingStyle, param.tweenTime)
    task.wait(param.tweenTime)
    comp.Visible = false
end

return controller