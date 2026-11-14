-- MM2 TP All to Me + Force Murderer by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local TPActive = false
local FreezeActive = false
local TPConnection = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadMM2TP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 250)
MainFrame.Position = UDim2.new(0, 20, 0, 60)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Bread MM2 Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Bouton TP sur MOI
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 42)
ToggleBtn.Position = UDim2.new(0, 10, 0, 38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "TP sur moi: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- Bouton FREEZE
local FreezeBtn = Instance.new("TextButton")
FreezeBtn.Size = UDim2.new(1, -20, 0, 35)
FreezeBtn.Position = UDim2.new(0, 10, 0, 85)
FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FreezeBtn.Text = "Freeze Joueurs: OFF"
FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FreezeBtn.TextSize = 14
FreezeBtn.Font = Enum.Font.GothamBold
FreezeBtn.BorderSizePixel = 0
FreezeBtn.AutoButtonColor = false
FreezeBtn.Parent = MainFrame

local FreezeCorner = Instance.new("UICorner")
FreezeCorner.CornerRadius = UDim.new(0, 6)
FreezeCorner.Parent = FreezeBtn

-- Bouton FORCE MURDERER
local MurderBtn = Instance.new("TextButton")
MurderBtn.Size = UDim2.new(1, -20, 0, 35)
MurderBtn.Position = UDim2.new(0, 10, 0, 125)
MurderBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
MurderBtn.Text = "Devenir Murderer"
MurderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MurderBtn.TextSize = 14
MurderBtn.Font = Enum.Font.GothamBold
MurderBtn.BorderSizePixel = 0
MurderBtn.AutoButtonColor = false
MurderBtn.Parent = MainFrame

local MurderCorner = Instance.new("UICorner")
MurderCorner.CornerRadius = UDim.new(0, 6)
MurderCorner.Parent = MurderBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 165)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Prêt."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DU SCRIPT =====

local function startTP()
    if TPConnection then return end
    ToggleBtn.Text = "TP sur moi: ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    TPConnection = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                
                if targetHRP then
                    -- TP du joueur sur TOI (avec un petit décalage)
                    targetHRP.CFrame = myHRP.CFrame + Vector3.new(math.random(-3,3), 3, math.random(-3,3))
                    
                    -- Si le freeze est activé
                    if FreezeActive then
                        targetHRP.Anchored = true 
                    end
                end
            end
        end
    end)
end

local function stopTP()
    if TPConnection then
        TPConnection:Disconnect()
        TPConnection = nil
    end
    ToggleBtn.Text = "TP sur moi: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    -- On enlève le freeze quand on désactive
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end
    StatusLabel.Text = "Status: Désactivé."
end

-- Fonction pour devenir Murderer (Spoof local)
local function forceMurderer()
    local char = LocalPlayer.Character
    if not char then return end
    
    StatusLabel.Text = "Status: Recherche du couteau..."
    
    -- On cherche le couteau dans tout le ReplicatedStorage
    local knife = nil
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("couteau")) then
            knife = v
            break
        end
    end
    
    if knife then
        local clonedKnife = knife:Clone()
        clonedKnife.Parent = char
        StatusLabel.Text = "Status: Couteau équipé (Spoof Local) !"
    else
        StatusLabel.Text = "Status: Couteau introuvable dans les fichiers."
    end
end

-- Gestion des boutons
local function bindButton(btn, onPress)
    local touchStartPos = nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            touchStartPos = input.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if touchStartPos and (input.Position - touchStartPos).Magnitude < 15 then
                onPress()
            end
            touchStartPos = nil
        end
    end)
end

bindButton(ToggleBtn, function()
    if TPConnection then stopTP() else startTP() end
end)

bindButton(FreezeBtn, function()
    FreezeActive = not FreezeActive
    if FreezeActive then
        FreezeBtn.Text = "Freeze Joueurs: ON"
        FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        FreezeBtn.Text = "Freeze Joueurs: OFF"
        FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end
        end
    end
end)

bindButton(MurderBtn, function()
    forceMurderer()
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopTP()
    ScreenGui:Destroy()
end)
