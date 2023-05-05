return {
    -- attributes
    hp = 100,  -- 血量
    walkSpeed = 16, -- 移速
    -- rewards
    onlineTime = 0, -- 在线时长
    dailyOnlineTime = 0,  -- 每日在线时长
    receivedOnlineTime = 0,  -- 已领取的在线时长奖励
    lastLoginTimeStamp = 0, -- 上次登录的时间戳
    inGroup = false, -- 是否在群组中
    inGroupReward = false, -- 是否领取了群组奖励
    liked = false, -- 是否点赞
    likedReward = false, -- 是否领取了点赞奖励
    firstPlay = true, -- 是否第一次游玩
    -- currency
    money = 0, -- 货币
}
