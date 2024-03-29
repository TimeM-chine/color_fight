-- ================================================================================
-- player data key name
-- ================================================================================

return {
    ---- attributes -----
    hp = "hp",  -- 血量
    wins = "wins", -- win 的数量
    totalWins = "totalWins", -- 总计 win 的数量
    walkSpeed = "walkSpeed", -- 移速
    shoe = "shoe", -- 鞋子情况
    career = "career", -- 职业情况
    chosenSkInd = "chosenSkInd", -- 选择的技能
    chosenShoeInd = "chosenShoeInd", -- 选择的鞋子
    levelUnlock = "levelUnlock", -- 关卡解锁情况
    chosenTail = "chosenTail", -- 装备的尾迹
    ownedTails = "ownedTails", -- 拥有的尾迹

    ---- rewards ----
    tempSpeedStart = "tempSpeedStart",  -- 临时的速度
    tempSkStart = "tempSkStart",  -- 临时的职业
    tempSpeedInfo = "tempSpeedInfo", -- 临时的速度信息
    tempSkInfo = "tempSkInfo", -- 临时的职业信息
    onlineTime = "onlineTime", -- 在线时长
    dailyOnlineTime = "dailyOnlineTime",  -- 每日在线时长
    receivedOnlineTime = "receivedOnlineTime",  -- 已领取的在线时长奖励
    lastLoginTimeStamp = "lastLoginTimeStamp", -- 上次登录的时间戳
    lastLeaveTimeStamp = "lastLeaveTimeStamp", -- 上次下线时间戳
    loginState = "loginState", -- 签到情况
    inGroup = "inGroup", -- 是否在群组中
    inGroupReward = "inGroupReward", -- 是否领取了群组奖励
    liked = "liked", -- 是否点赞
    likedReward = "likedReward", -- 是否领取了点赞奖励
    firstPlay = "firstPlay", -- 是否第一次游玩
    friendsInvitedNum = "friendsInvitedNum", -- 邀请好友数
    friendsInvited = "friendsInvited", -- 邀请过的好友
    friendsRewards = "friendsRewards", -- 已领取的好友奖励
    cdKeyUsed = "cdKeyUsed", -- 已使用的cd key
    ----- currency -----
    money = "money", -- 货币
    consumptionSum = "consumptionSum",  -- 总消费金额
    donate = "donate", -- 捐赠金额
    ----- rank list ----
    lv1Wins = "lv1Wins",  -- 第一关通关次数
    lv2Wins = "lv2Wins",  -- 第二关通关次数
    lv1Time = "lv1Time", -- 第一关通关时间
    lv2Time = "lv2Time", -- 第二关通关时间
}
