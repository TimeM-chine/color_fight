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

argsEnum.SimplePath = {
    TIME_VARIANCE = 0.07;
    COMPARISON_CHECKS = 1;
    JUMP_WHEN_STUCK = true;
}

argsEnum.CreatePath = {
    AgentRadius = 2, --Determines the minimum amount of horizontal space required for empty space to be considered traversable.
    AgentHeight = 5, --Determines the minimum amount of vertical space required for empty space to be considered traversable.
    AgentCanJump = true, --Determines whether jumping during pathfinding is allowed.
    AgentCanClimb = false, --Determines whether climbing TrussParts during pathfinding is allowed.
    WaypointSpacing = 4, --Determines the spacing between intermediate waypoints in path.
    Costs = {}, --Table of materials or defined PathfindingModifiers and their "cost" for traversal. Useful for making the agent prefer certain materials/regions over others. See here for details.
}

return argsEnum
