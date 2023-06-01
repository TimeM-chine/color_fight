local TS = game:GetService("TweenService")
local BasePartCls = require(game.StarterPlayer.StarterPlayerScripts.classes.BasePartCls)
---- main ----

local TransChangePart = setmetatable({
    lapse = 0,
    startTrans = 0,
    endTrans = 1,
    changeTime = 2,
    suspendTime = 0,
    transCollide = false,
}, BasePartCls)
TransChangePart.__index = TransChangePart


function TransChangePart.new(part:Part)
    local ins = setmetatable(getmetatable(TransChangePart).new(part, part.TransChangePart), TransChangePart)

    local lapse = ins.folder:FindFirstChild("lapse")
    ins.lapse = lapse and lapse.Value or 0
    local startTrans = ins.folder:FindFirstChild("start")
    ins.startTrans = startTrans and startTrans.Value or 0
    local endTrans = ins.folder:FindFirstChild("end")
    ins.endTrans = endTrans and endTrans.Value or 1
    local changeTime = ins.folder:FindFirstChild("changeTime")
    ins.changeTime = changeTime and changeTime.Value or 1
    local suspendTime = ins.folder:FindFirstChild("suspendTime")
    ins.suspendTime = suspendTime and suspendTime.Value or ins.suspendTime
    local transCollide = ins.folder:FindFirstChild("transCollide")
    ins.transCollide = transCollide and transCollide.Value or ins.transCollide

    coroutine.resume(coroutine.create(function()
        ins:Init()
    end))
    return ins
end

function TransChangePart:Init()
    task.wait(self.lapse)
    local tweenInfo = TweenInfo.new(self.changeTime, Enum.EasingStyle.Linear)

    local function anim(aPart)
        local tween = TS:Create(aPart, tweenInfo, {
            Transparency = self.endTrans
        })
        local reverseTween = TS:Create(aPart, tweenInfo, {
            Transparency = self.startTrans
        })
        while task.wait(self.changeTime) do
            tween:Play()
            if self.transCollide == false then
                task.delay(self.changeTime * 0.5, function()
                    aPart.CanCollide = false
                end)
            end
            task.wait(self.changeTime + self.suspendTime)
            reverseTween:Play()
            if self.transCollide == false then
                task.delay(self.changeTime * 0.5, function()
                    aPart.CanCollide = true
                end)
            end
            task.wait(self.suspendTime)
        end
    end

    if self.part:IsA("Model") then
        for _, descendant in self.part:GetDescendants() do
            if descendant:IsA("BasePart") then
                local tween = TS:Create(descendant, tweenInfo, {
                    Transparency = self.endTrans
                })
                local reverseTween = TS:Create(descendant, tweenInfo, {
                    Transparency = self.startTrans
                })
                coroutine.resume(coroutine.create(function()
                    tween:Play()
                    task.wait(self.changeTime + self.suspendTime)
                    reverseTween:Play()
                    task.wait(self.suspendTime)
                    anim(descendant)
                end))
            end
        end
    else
        local tween = TS:Create(self.part, tweenInfo, {
            Transparency = self.endTrans
        })
        local reverseTween = TS:Create(self.part, tweenInfo, {
            Transparency = self.startTrans
        })
        tween:Play()
        task.wait(self.changeTime + self.suspendTime)
        reverseTween:Play()
        task.wait(self.suspendTime)
        coroutine.resume(coroutine.create(function()
            anim(self.part)
        end))
    end

end


return TransChangePart
