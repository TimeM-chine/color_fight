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
local SkillModule = require(game.Players.LocalPlayer.PlayerScripts.modules.SkillModule)

---- enums ----
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

---- variables ----
local localPlayer = game.Players.LocalPlayer
local unitsFolder = localPlayer.PlayerGui.units
local chosenSkInd = playerModule.GetPlayerOneData(dataKey.chosenSkInd)
local showingShoeListFrame

local shopFrameClass = {}
shopFrameClass.__index = shopFrameClass
shopFrameClass.frame = nil
shopFrameClass.connections = {}

function shopFrameClass.new(frame)
    chosenSkInd = playerModule.GetPlayerOneData(dataKey.chosenSkInd)
    local ins = setmetatable({}, shopFrameClass)
    -- print("init frame,", frame)
    ins.frame = frame
    ins.closeBtn = frame.closeBtn
    ins.shoeShopBtn = frame.shoeShopBtn
    ins.careerShopBtn = frame.careerShopBtn
    ins.connections = {}
    local con = ins.closeBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:DestroyIns()
        uiController.PopScreen()
    end)
    table.insert(ins.connections, con)


    con = ins.shoeShopBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:CheckShoes()
        ins:OpenShoeShop()
    end)
    table.insert(ins.connections, con)


    con = ins.careerShopBtn.MouseButton1Click:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:CheckCareer()
        ins:OpenCareerShop()
    end)
    table.insert(ins.connections, con)

    con = remoteEvents.refreshScreenEvent.OnClientEvent:Connect(function()
        localPlayer.Character.HumanoidRootPart.clickUI:Play()

        ins:RefreshCareer()
        ins:RefreshShoes()
    end)
    table.insert(ins.connections, con)

    ins:CheckCareer()
    ins:OpenCareerShop()
    return ins

end


function shopFrameClass:RefreshCareer()
    local career = playerModule.GetPlayerOneData(dataKey.career)
    for i = 1, #career do
        local careerFrame = self.frame.careerShopFrame.ScrollingFrame["career" .. i]
        local confirmBtn = careerFrame.Frame.Frame.confirm
        if career[i] then
            confirmBtn.Text = "Equip"
            confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.066666, 0.858823, 0.372549))
            if i == chosenSkInd then
                confirmBtn.Text = "Remove"
                confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.858823, 0.066666, 0.066666))
            end
        else
            confirmBtn.Text = "Buy"
            confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.984313, 1, 0.070588))
        end
    end
end

function shopFrameClass:CheckCareer()
    local career = playerModule.GetPlayerOneData(dataKey.career)
    local tempSkInfo = playerModule.GetPlayerOneData(dataKey.tempSkInfo)
    local tempSkStart = playerModule.GetPlayerOneData(dataKey.tempSkStart)

    for i=1, #career do
        local careerFrame = self.frame.careerShopFrame.ScrollingFrame["career"..i]
        local confirmBtn:TextButton = careerFrame.Frame.Frame.confirm
        local con

        if career[i] then
            confirmBtn.Text = "Equip"
            confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.066666, 0.858823, 0.372549))
            if i == chosenSkInd then
                confirmBtn.Text = "Remove"
                confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.858823, 0.066666, 0.066666))
            end
        else
            confirmBtn.Text = "Buy"
            confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.984313, 1, 0.070588))
        end

        if confirmBtn.Text == "Buy" then
            if i == tempSkInfo[1] and os.time() - tempSkStart <= tempSkInfo[2] then
                confirmBtn.Text = "Equip"
                confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.066666, 0.858823, 0.372549))
                if i == chosenSkInd then
                    confirmBtn.Text = "Remove"
                    confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.858823, 0.066666, 0.066666))
                end
            end
        end

        con = confirmBtn.MouseButton1Click:Connect(function()
            if confirmBtn.Text == "Buy" then
                MarketplaceService:PromptProductPurchase(localPlayer, productIdEnum.career["sk"..i])
                -- confirmBtn.Text = "Equip"
            elseif confirmBtn.Text == "Equip" then
                uiController.SetNotification("success", "top")
                if chosenSkInd > 0 then
                    local btn = self.frame.careerShopFrame.ScrollingFrame["career"..chosenSkInd].Frame.Frame.confirm
                    btn.Text = "Equip"
                    btn.UIGradient.Color = ColorSequence.new(Color3.new(0.066666, 0.858823, 0.372549))
                end
                chosenSkInd = i
                confirmBtn.Text = "Remove"
                confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.858823, 0.066666, 0.066666))

                SkillModule.SetSkillId(i)
            elseif confirmBtn.Text == "Remove" then
                print("player reset career", i)
                uiController.SetNotification("success", "top")
                confirmBtn.Text = "Equip"
                confirmBtn.UIGradient.Color = ColorSequence.new(Color3.new(0.066666, 0.858823, 0.372549))

                SkillModule.SetSkillId(0)
            end
        end)

        table.insert(self.connections, con)
    end

end

function shopFrameClass:RefreshShoes()
    local shoe = playerModule.GetPlayerOneData(dataKey.shoe)
    local scrollingFrame = self.frame.shoeShopFrame.ScrollingFrame
    for i = 1, 3 do
        scrollingFrame["shoe"..i].confirm.Visible = false
        for j = 1,5 do
            if not shoe[i][j] then
                scrollingFrame["shoe"..i].confirm.Visible = true
                break
            end
        end
    end
end


function shopFrameClass:CheckShoes()
    local shoe = playerModule.GetPlayerOneData(dataKey.shoe)
    local scrollingFrame = self.frame.shoeShopFrame.ScrollingFrame
    
    for i = 1, 3 do
        scrollingFrame["shoe"..i].confirm.Visible = false
        for j = 1,5 do
            if not shoe[i][j] then
                scrollingFrame["shoe"..i].confirm.Visible = true
                break
            end
        end
        
        local con = scrollingFrame["shoe"..i].confirm.MouseButton1Click:Connect(function()
            if showingShoeListFrame then
                showingShoeListFrame.Visible = false
            end
            MarketplaceService:PromptProductPurchase(localPlayer, productIdEnum.shoes["shoe"..i])
        end)

        table.insert(self.connections, con)
        con = scrollingFrame["shoe"..i].choose.MouseButton1Click:Connect(function()
            local shoeList = playerModule.GetPlayerOneData(dataKey.shoe)
            if showingShoeListFrame then
                showingShoeListFrame.Visible = false
            end
            showingShoeListFrame = scrollingFrame["shoe"..i].choose.shoeList

            for _, ctrl in showingShoeListFrame.ScrollingFrame:GetChildren() do
                if ctrl:IsA("ImageButton") then
                    ctrl:Destroy()
                end
            end

            for ind = 1, 5 do
                if shoeList[i][ind] then
                    local shoeBtn:ImageButton = unitsFolder.shoeButton:Clone()
                    shoeBtn.Name = ind
                    shoeBtn.Image = TextureIds.shoeImg[i][ind]
                    shoeBtn.MouseButton1Click:Connect(function()
                        remoteEvents.putonShoeEvent:FireServer(i, ind)
                        localPlayer.Character.Humanoid.WalkSpeed = playerModule.GetPlayerSpeed()
                        uiController.SetNotification("Put on new shoes.")
                    end)
                    shoeBtn.Parent = showingShoeListFrame.ScrollingFrame
                end
            end
            showingShoeListFrame.Visible = true
        end)
        table.insert(self.connections, con)
    end

end

function shopFrameClass:DestroyIns()
    -- print(self, "destroy")
    for _, con in self.connections do
        con:Disconnect()
    end

    for key, _ in self do
        self[key] = nil
    end
end

function shopFrameClass:OpenShoeShop()
    self.frame.careerShopFrame.Visible = false
    self.frame.shoeShopFrame.Visible = true
end

function shopFrameClass:OpenCareerShop()
    self.frame.careerShopFrame.Visible = true
    self.frame.shoeShopFrame.Visible = false
end

return shopFrameClass
