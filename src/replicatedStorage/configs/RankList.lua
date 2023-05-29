local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

local RankList = {}

RankList.count = 100
RankList.freshTime = universalEnum.oneMinute * 2

RankList.listNames = {
    lv1Time = "lv1Time",
    lv2Time = "lv2Time",
    lv1Win = "lv1Win",
    lv2Win = "lv2Win",
}


return RankList
