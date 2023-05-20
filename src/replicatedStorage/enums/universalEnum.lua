local universalEnum = {}

universalEnum.normalSpeed = 16

universalEnum.maxHealth = 6

universalEnum.oneHour = 3600
universalEnum.oneMinute = 60
universalEnum.oneDay = universalEnum.oneHour * 24
universalEnum.oneWeek = universalEnum.oneDay * 7

universalEnum.gameStartTimeStamp = 1684195200-universalEnum.oneDay -- UTC 2023-05-16 00:00:00
universalEnum.gameStartDay = math.floor(universalEnum.gameStartTimeStamp/universalEnum.oneDay)


return universalEnum
