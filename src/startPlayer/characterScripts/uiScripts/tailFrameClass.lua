-- ================================================================================
-- init when shop frame is pushed
-- ================================================================================

---- services ----
local MarketplaceService = game:GetService"MarketplaceService"

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- modules ----
local uiController = require(script.Parent.uiController)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local GameConfig = require(game.ReplicatedStorage.configs.GameConfig)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)


---- variables ----
local localPlayer = game.Players.LocalPlayer
local unitsFolder = localPlayer.PlayerGui.units
local nowTailId = 1

local tailFrameClass = {}
tailFrameClass.__index = tailFrameClass
tailFrameClass.frame = nil
tailFrameClass.connections = {}
tailFrameClass.scrollingFrame = nil

function tailFrameClass.new(frame)
    local ins = setmetatable({}, tailFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = frame.closeBtn
    ins.scrollingFrame = frame.inner.ScrollingFrame
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)
 
    con = remoteEvents.refreshScreenEvent.OnClientEvent:Connect(function()
        ins:Refresh()
    end)

    table.insert(ins.connections, con)

    ins:ChooseTail(1)
    ins:Init()

    return ins

end

function tailFrameClass:ChooseTail(i)
    nowTailId = i
    local showCase = self.frame.inner.showCase
    local ownedTails = playerModule.GetPlayerOneData(dataKey.ownedTails)
    local chosenTail = playerModule.GetPlayerOneData(dataKey.chosenTail)
    if chosenTail == i then
        showCase.confirmBtn.Text = "UnEquip"
        showCase.confirmBtn.BackgroundColor3 = Color3.new(1, 0, 0)
    elseif ownedTails[i] then
        showCase.confirmBtn.Text = "Equip"
        showCase.confirmBtn.BackgroundColor3 = Color3.new(0, 1, 0)
    else
        showCase.confirmBtn.Text = "Buy"
        showCase.confirmBtn.BackgroundColor3 = Color3.new(0, 1, 0)
    end

    local iconFrame = showCase.iconFrame
    iconFrame.tailIcon.Image = self.scrollingFrame['tailUnit'..i].ImageLabel.Image
    iconFrame.priceIcon.Image = self.scrollingFrame['tailUnit'..i].priceIcon.Image
    iconFrame.price.Text = self.scrollingFrame['tailUnit'..i].price.Text

end



function GetNowTailId()
    return nowTailId
end

function tailFrameClass:Init()
    local nowWins = playerModule.GetPlayerOneData(dataKey.wins)
    local winTxt = self.frame.inner.win.win.wins
    winTxt.Text = nowWins
    for i = 1, #GameConfig.tailConfig do
        local btn = self.scrollingFrame['tailUnit'..i].TextButton
        local con = btn.MouseButton1Click:Connect(function()
            self:ChooseTail(i)
        end)

        table.insert(self.connections, con)
    end

    local showCase = self.frame.inner.showCase
    local con = showCase.confirmBtn.MouseButton1Click:Connect(function()
        if showCase.confirmBtn.Text == "Buy" then
            local i = GetNowTailId()
            if not GameConfig.tailConfig[i].winPrice then
                MarketplaceService:PromptProductPurchase(localPlayer, productIdEnum.tenWins)
                return
            end

            nowWins = playerModule.GetPlayerOneData(dataKey.wins)
            uiController.ShowModalFrame(`This Tail cost {GameConfig.tailConfig[i].winPrice} wins, you have {nowWins} wins, sure to buy?`, function(args)
                if nowWins < GameConfig.tailConfig[i].winPrice then
                    MarketplaceService:PromptProductPurchase(localPlayer, productIdEnum.tenWins)
                    uiController.SetNotification("not enough wins", "top")
                else
                    remoteEvents.buyTailByWin:FireServer(nowTailId)
                end
            end)
        elseif showCase.confirmBtn.Text == "Equip" then
            local i = GetNowTailId()
            remoteEvents.operateTail:FireServer("Equip", i)
        else
            remoteEvents.operateTail:FireServer("UnEquip")
        end
    end)

    table.insert(self.connections, con)
end


function tailFrameClass:Refresh()
    local nowWins = playerModule.GetPlayerOneData(dataKey.wins)
    local winTxt = self.frame.inner.win.win.wins
    winTxt.Text = nowWins
    local i = GetNowTailId()
    self:ChooseTail(i)
end


function tailFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end
    for key, _ in self do
        self[key] = nil
    end
end


return tailFrameClass
