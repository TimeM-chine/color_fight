local TS = game:GetService("TweenService")
local BasePartCls = require(game.StarterPlayer.StarterPlayerScripts.classes.BasePartCls)
---- main ----

local MovingPart = setmetatable({
    lapse = 0,
    offset = Vector3.new(0, 0, 1),
    changeTime = 2,
    suspendTime = 0,
}, BasePartCls)
MovingPart.__index = MovingPart


function MovingPart.new(part:Part)
	local ins
	if part:IsA("Model") then
		part = part.PrimaryPart
		ins = setmetatable(getmetatable(MovingPart).new(part, part.Parent.MovingPart), MovingPart)
	else
		ins = setmetatable(getmetatable(MovingPart).new(part, part.MovingPart), MovingPart)
	end

    local lapse = ins.folder:FindFirstChild("lapse")
    ins.lapse = lapse and lapse.Value or 0
    local offset = ins.folder:FindFirstChild("offset")
    ins.offset = offset and offset.Value or ins.offset
    local changeTime = ins.folder:FindFirstChild("changeTime")
    ins.changeTime = changeTime and changeTime.Value or 1
    local suspendTime = ins.folder:FindFirstChild("suspendTime")
    ins.suspendTime = suspendTime and suspendTime.Value or ins.suspendTime

    coroutine.resume(coroutine.create(function()
        ins:Init()
    end))
    return ins
end

function MovingPart:Init()
	task.wait(self.lapse)

    local tweenInfo = TweenInfo.new(self.changeTime, Enum.EasingStyle.Linear)
    local tween = TS:Create(self.part, tweenInfo, {
        CFrame = self.part.CFrame + self.offset
    })
    local reverseTween = TS:Create(self.part, tweenInfo, {
        CFrame = self.part.CFrame
	})

	local function anim()
		while task.wait(self.changeTime) do
			tween:Play()
			task.wait(self.changeTime + self.suspendTime)
			reverseTween:Play()
			task.wait(self.suspendTime)
		end
	end

	tween:Play()
	task.wait(self.changeTime + self.suspendTime)
    reverseTween:Play()
    task.wait(self.suspendTime)
    coroutine.resume(coroutine.create(anim))

end


return MovingPart
