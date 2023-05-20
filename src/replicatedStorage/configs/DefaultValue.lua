return {
    ---- attributes -----
    hp = 1,  -- 血量
    wins = 0, -- win 的数量， 会被消耗
    totalWins = 0, -- 总计 win 的数量
    walkSpeed = 16, -- 移速
    shoe = {
        false, false, false, false
    }, -- 鞋子情况
    career = {
        false, false, false, false, false
    }, -- 职业情况
    chosenSkInd = 0, -- 选择的技能
    chosenShoeInd = 0, -- 选择的鞋子
    ---- rewards ----
    onlineTime = 0, -- 在线时长
    dailyOnlineTime = 0,  -- 每日在线时长
    receivedOnlineTime = 0,  -- 已领取的在线时长奖励
    lastLoginTimeStamp = 0, -- 上次登录的时间戳
    lastLeaveTimeStamp = 0, -- 上次下线时间戳
    loginState = {false, false, false, false, false, false, false}, -- 签到情况
    inGroup = false, -- 是否在群组中
    inGroupReward = false, -- 是否领取了群组奖励
    liked = false, -- 是否点赞
    likedReward = false, -- 是否领取了点赞奖励
    firstPlay = true, -- 是否第一次游玩
    friendsInvitedNum = 0, -- 邀请好友数
    ----- currency -----
    money = 0, -- 货币
    consumptionSum = 0,  -- 总消费金额
}
