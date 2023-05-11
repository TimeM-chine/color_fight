-- ================================================================================
-- ui controller
-- ================================================================================


---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local pushScreenGui = PlayerGui.pushScreen
local hudScreenGui = PlayerGui.hudScreen
local notificationScreen = PlayerGui.notificationScreen
local notificationFrame = notificationScreen.notificationFrame
local noteCrt = {top=nil, middle=nil, bottom=nil}

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

    local frame = screenIns:Clone()
    local frameClass = script.Parent:FindFirstChild(screenName.."Class")
    if frameClass then
        local cls = require(frameClass)
        cls.new(frame)
    else
        warn(`There is no screen class named {screenName.."Class"}`)
    end
    frame.Parent = pushScreenGui.bgFrame
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

-- set notification (top, middle, bottom)
function controller.SetNotification(content, noteType)
    noteType = noteType or "bottom"
    local noteLabel = notificationFrame[noteType]
    noteLabel.Visible = true
    noteLabel.Text = content
    if noteCrt[noteType] then
        coroutine.close(noteCrt[noteType])
    end
    noteCrt[noteType] = coroutine.create(function()
        noteLabel.TextTransparency = 0
        task.wait(2)
        for i=1, 20 do
            noteLabel.TextTransparency = i/20
            task.wait(0.05)
        end
        noteLabel.Visible = false
    end)
    coroutine.resume(noteCrt[noteType])
end

return controller
