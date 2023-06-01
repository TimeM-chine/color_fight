local BasePartCls = require(game.StarterPlayer.StarterPlayerScripts.classes.BasePartCls)
local TS = game:GetService("TweenService")

---- main ----
local SizeChangePart = setmetatable({
    startSize = nil,
    endSize = nil,
    lapse = 0,
    changeTime = 1,
    suspendTime = 0,
}, BasePartCls)
SizeChangePart.__index = SizeChangePart


function SizeChangePart.new(part:Part)
    local ins = setmetatable(getmetatable(SizeChangePart).new(part, part.SizeChangePart), SizeChangePart)

    local lapse = ins.folder:FindFirstChild("lapse")
    ins.lapse = lapse and lapse.Value or 0
    local startSize = ins.folder:FindFirstChild("start")
    ins.startSize = startSize and startSize.Value or part.Size
    local endSize = ins.folder:FindFirstChild("end")
    ins.endSize = endSize and endSize.Value or Vector3.new(0, 0, 0)
    local changeTime = ins.folder:FindFirstChild("changeTime")
    ins.changeTime = changeTime and changeTime.Value or 1
    local suspendTime = ins.folder:FindFirstChild("suspendTime")
    ins.suspendTime = suspendTime and suspendTime.Value or ins.suspendTime

    coroutine.resume(coroutine.create(function()
        ins:Init()
    end))
    return ins
end

function SizeChangePart:Init()
    task.wait(self.lapse)
    local tweenInfo = TweenInfo.new(self.changeTime)
    local tween = TS:Create(self.part, tweenInfo, {
        Size = self.endSize
    })
    local reverseTween = TS:Create(self.part, tweenInfo, {
        Size = self.startSize
    })
    local function anim()
        while task.wait(self.changeTime * 2 + self.suspendTime) do
            tween:Play()
            task.wait(self.suspendTime)
            reverseTween:Play()
        end
    end
    coroutine.resume(coroutine.create(anim))


end


return SizeChangePart
