-- ================================================================================
-- arguments enum -> client and server side
-- ================================================================================


local argsEnum = {}

argsEnum.TweenArgs = {
    easingDir = Enum.EasingDirection.Out,
    easingStyle = Enum.EasingStyle.Quad,
    tweenTime = 0.5
}

---- event enum ----
argsEnum.lotteryEvent = {
    times = 1,
}

argsEnum.shoppingEvent = {
    goodsId = 0,
}


argsEnum.changeColorEvent = {
    color = nil
}

return argsEnum
