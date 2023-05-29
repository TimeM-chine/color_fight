return {
    ---- attributes -----
    hp = 1,  -- 血量
    wins = 0, -- win 的数量， 会被消耗
    totalWins = 0, -- 总计 win 的数量
    walkSpeed = 16, -- 移速
    shoe = {
        {false, false, false, false, false},
        {false, false, false, false, false},
        {false, false, false, false, false}
    }, -- 鞋子情况
    career = {
        false, false, false, false, false
    }, -- 职业情况
    chosenSkInd = 0, -- 选择的技能
    chosenShoeInd = {0, 0}, -- 选择的鞋子
    levelUnlock = {true, false, false, false, false}, -- 关卡解锁情况

    ---- rewards ----
    tempSpeedStart = 0,  -- 临时的速度
    tempSkStart = 0,  -- 临时的职业
    tempSpeedInfo = {0, 0}, -- 临时的速度信息
    tempSkInfo = {0, 0}, -- 临时的职业信息
    onlineTime = 0, -- 在线时长
    dailyOnlineTime = 0,  -- 每日在线时长
    receivedOnlineTime = {false, false, false, false, false, false, false},  -- 已领取的在线时长奖励
    lastLoginTimeStamp = 0, -- 上次登录的时间戳
    lastLeaveTimeStamp = 0, -- 上次下线时间戳
    loginState = {false, false, false, false, false, false, false}, -- 签到情况
    inGroup = false, -- 是否在群组中
    inGroupReward = false, -- 是否领取了群组奖励
    liked = false, -- 是否点赞
    likedReward = false, -- 是否领取了点赞奖励
    firstPlay = true, -- 是否第一次游玩
    friendsInvitedNum = 0, -- 邀请好友数
    friendsInvited = {}, -- 已邀请的好友
    friendsRewards = {}, -- 已领取的好友奖励
    cdKeyUsed = {}, -- 已使用的cd key

    ----- currency -----
    money = 0, -- 货币
    consumptionSum = 0,  -- 总消费金额

    ----- rank list ----
    lv1Wins = 0,  -- 第一关通关次数
    lv2Wins = 0,  -- 第二关通关次数
    lv1Time = 999999, -- 第一关通关时间
    lv2Time = 999999, -- 第二关通关时间

}
