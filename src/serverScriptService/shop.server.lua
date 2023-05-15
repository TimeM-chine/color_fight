-- ================================================================================
-- lottery server --> server side
-- ================================================================================

---- services ----
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local PlayerService = game:GetService("Players")

---- variables ----
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

---- modules -----
local ServerSystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)

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

local productFunctions = {}
productFunctions[productIdEnum.goods1] = emptyHandle


local function processReceipt(receiptInfo)
	print(`playerId {receiptInfo.PlayerId} is purchasing {receiptInfo.PurchaseId}.`)

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