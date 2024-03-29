-- ================================================================================
-- lottery server --> server side
-- ================================================================================

---- services ----
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local PlayerService = game:GetService("Players")

---- variables ----
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

---- modules -----
local ServerSystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)
local BillboardManager = require(game.ServerScriptService.modules.BillboardManager)
local TableModule = require(game.ReplicatedStorage.modules.TableModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local BindableEvents = game.ReplicatedStorage.BindableEvents

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local GameConfig = require(game.ReplicatedStorage.configs.GameConfig)

local shopServer = ServerSystemClass.new()


function shoppingEventRecall(player, args)
    local itemId = args.itemId
    local itemNum = args.itemNum
    local price = 100

    local playerIns = PlayerServerClass.GetIns(player)
    local money = playerIns:GetPlayerOneData(dataKey.money)
    if money >= price then
        playerIns:UpdatedOneData(dataKey.money, -price)
        playerIns:AddItem(itemId, itemNum)
    else
        
    end

end

shopServer:ListenForEvent(RemoteEvents.shoppingEvent, shoppingEventRecall)


function emptyHandle(receipt, player)
	warn(`player {player.Name} bought item {receipt.ProductId}, but there is no handle.`)
	return true
end


function AddHealth(receipt, player)
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:AddHealth()
    return true
end

function BackToGame(receipt, player)
    local force = Instance.new("ForceField")
    force.Parent = player.Character
    Debris:AddItem(force, 15)
    player.Character.beforeDeath.Value = false
    RemoteEvents.playerLiveBackEvent:FireClient(player)
    return true
end

function BuyShoes(receipt, player)
    local playerIns = PlayerServerClass.GetIns(player)
    local shoeList = playerIns:GetOneData(dataKey.shoe)
    local shoeInd
    for key, value in productIdEnum.shoes do
        if value == receipt.ProductId then
            shoeInd = tonumber(string.sub(key, 5, 5))
            local shoeLeft = {}
            for i=1,5 do
                if not shoeList[shoeInd][i] then
                    table.insert(shoeLeft, i)
                end
            end
            local number = TableModule.Choices(shoeLeft)
            shoeList[shoeInd][number[1]] = true
            RemoteEvents.refreshScreenEvent:FireClient(player)
            BindableEvents.putonShoesEvent:Fire(player,shoeInd, number[1])
            return true
        end
    end
end

function BuyCareers(receipt, player)
    local playerIns = PlayerServerClass.GetIns(player)
    local careerList = playerIns:GetOneData(dataKey.career)
    local careerInd
    for key, value in productIdEnum.career do
        if value == receipt.ProductId then
            careerInd = tonumber(string.sub(key, 3, 3))
            careerList[careerInd] = true
            RemoteEvents.refreshScreenEvent:FireClient(player)
            return true
        end
    end
    return `there is no career product {receipt.ProductId}`
end

RemoteEvents.buyCareerByWin.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    local careerList = playerIns:GetOneData(dataKey.career)
    playerIns:UpdatedOneData(dataKey.wins, -GameConfig.careerWinPrice[ind])
    careerList[ind] = true
    GAModule:addDesignEvent(player.UserId, {
        eventId = `buyCareerByWin:career{ind}`
    })
    RemoteEvents.refreshScreenEvent:FireClient(player)
end)

function Donate(receipt, player:Player)
    local playerIns = PlayerServerClass.GetIns(player)
    for num, pid in productIdEnum.donate do
        if receipt.ProductId == pid then
            playerIns:UpdatedOneData(dataKey.donate, num)
            BillboardManager.savePlayerRankData(player.UserId, playerIns:GetOneData(dataKey.donate), "donate")
            return true
        end
    end
end

function Navigation(receipt, player:Player)
    RemoteEvents.buyNavigation:FireClient(player)
    return true
end

function BuyTails(receipt, player)
    local playerIns = PlayerServerClass.GetIns(player)
    local ownedTails = playerIns:GetOneData(dataKey.ownedTails)
    local tailInd
    for key, value in productIdEnum.tails do
        if value == receipt.ProductId then
            tailInd = key
            ownedTails[12] = true
            -- ownedTails[4] = true
            RemoteEvents.refreshScreenEvent:FireClient(player)
            return true
        end
    end
    return `there is no career product {receipt.ProductId}`
end

function BuyWins(receipt, player)
    local playerIns = PlayerServerClass.GetIns(player)

    if receipt.ProductId == productIdEnum.win10 then
        playerIns:UpdatedOneData(dataKey.wins, 10)
    elseif receipt.ProductId == productIdEnum.win28 then
        playerIns:UpdatedOneData(dataKey.wins, 28)
    elseif receipt.ProductId == productIdEnum.win68 then
        playerIns:UpdatedOneData(dataKey.wins, 68)
    elseif receipt.ProductId == productIdEnum.win128 then
        playerIns:UpdatedOneData(dataKey.wins, 128)
    end
    RemoteEvents.refreshScreenEvent:FireClient(player)
    return `there is no wins product {receipt.ProductId}`
end

RemoteEvents.buyTailByWin.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:UpdatedOneData(dataKey.wins, -GameConfig.tailConfig[ind].winPrice)
    local ownedTails = playerIns:GetOneData(dataKey.ownedTails)
    ownedTails[ind] = true
    RemoteEvents.refreshScreenEvent:FireClient(player)
end)


local productFunctions = {}
for _, value in productIdEnum.career do
    productFunctions[value] = BuyCareers
end

for _, value in productIdEnum.shoes do
    productFunctions[value] = BuyShoes
end

for _, value in productIdEnum.donate do
    productFunctions[value] = Donate
end

for _, value in productIdEnum.tails do
    productFunctions[value] = BuyTails
end

productFunctions[productIdEnum.heart] = AddHealth
productFunctions[productIdEnum.backGame] = BackToGame
productFunctions[productIdEnum.navigation] = Navigation


local function processReceipt(receiptInfo)
	print(`playerId {receiptInfo.PlayerId} is purchasing {receiptInfo.ProductId}.`)
    GAModule:ProcessReceiptCallback(receiptInfo)
	-- check whether player bought this product before
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- if there is a record, then this receipt is done
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	-- get online player
	local player = PlayerService:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- player left game
		-- when player is back, the recall will call again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- check handle
	if not productFunctions[receiptInfo.ProductId] then
		SetGoodRecall(receiptInfo.ProductId, emptyHandle)
	end
	local handler = productFunctions[receiptInfo.ProductId]

	-- result check
    local result
	success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		print("\nResult", result)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 将购买操作记录在数据库中
	success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt

---- Apis ----
function SetGoodRecall(productId, recall)
	productFunctions[productId] = recall
end
