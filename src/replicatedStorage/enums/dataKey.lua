-- ================================================================================
-- player data key name
-- ================================================================================

return {
    ---- attributes -----
    hp = "hp",  -- 血量
    wins = "wins", -- win 的数量
    walkSpeed = "walkSpeed", -- 移速
    shoe = "shoe", -- 鞋子情况
    career = "career", -- 职业情况
    ---- rewards ----
    onlineTime = "onlineTime", -- 在线时长
    dailyOnlineTime = "dailyOnlineTime",  -- 每日在线时长
    receivedOnlineTime = "receivedOnlineTime",  -- 已领取的在线时长奖励
    lastLoginTimeStamp = "lastLoginTimeStamp", -- 上次登录的时间戳
    signInDay = "signInDay", -- 签到天数
    lastSignDay = "lastSignDay", -- 上次签到的天
    inGroup = "inGroup", -- 是否在群组中
    inGroupReward = "inGroupReward", -- 是否领取了群组奖励
    liked = "liked", -- 是否点赞
    likedReward = "likedReward", -- 是否领取了点赞奖励
    firstPlay = "firstPlay", -- 是否第一次游玩
    friendsInvitedNum = "friendsInvitedNum", -- 邀请好友数
    ----- currency -----
    money = "money", -- 货币
    consumptionSum = "consumptionSum",  -- 总消费金额
}
