-- MM2 TP All to Murderer by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local TPActive = false
local TPConnection = nil

-- Interface GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadMM2TP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 130)
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
Title.Text = "MM2 TP to Murderer"
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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 42)
ToggleBtn.Position = UDim2.new(0, 10, 0, 38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Activer TP: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: En attente..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DU SCRIPT =====

-- Fonction pour trouver le Murderer
-- Note: MM2 stocke les rôles de différentes manières, on va chercher les indices visuels
local function getMurderer()
    local murderer = nil
    
    -- Méthode 1 : Chercher un joueur qui a un couteau (outil) dans son personnage
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("couteau")) then
                    return player
                end
            end
        end
    end
    
    -- Méthode 2 : Chercher via les attributs du jeu (si le jeu utilise ce système)
    for _, player in pairs(Players:GetPlayers()) do
        if player:GetAttribute("Role") == "Murderer" or player:GetAttribute("IsMurderer") == true then
            return player
        end
    end
    
    return murderer
end

local function startTP()
    if TPConnection then return end
    ToggleBtn.Text = "Activer TP: ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    TPConnection = RunService.Heartbeat:Connect(function()
        local murderer = getMurderer()
        if not murderer or not murderer.Character then
            StatusLabel.Text = "Status: Murderer introuvable."
            return
        end
        
        local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not murdererHRP then return end
        
        StatusLabel.Text = "Status: TP vers " .. murderer.Name
        
        -- Téléporte TOUS les autres joueurs sur le Murderer
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= murderer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    -- On TP un peu au-dessus pour éviter que les joueurs ne se superposent
                    targetHRP.CFrame = murdererHRP.CFrame + Vector3.new(math.random(-3,3), 3, math.random(-3,3))
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
    ToggleBtn.Text = "Activer TP: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    StatusLabel.Text = "Status: Désactivé."
end

-- Gestion du bouton ON/OFF
local touchStartPos = nil
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchStartPos = input.Position
    end
end)

ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if touchStartPos and (input.Position - touchStartPos).Magnitude < 15 then
            if TPConnection then stopTP() else startTP() end
        end
        touchStartPos = nil
    end
end)

-- Bouton Fermer
CloseBtn.MouseButton1Click:Connect(function()
    stopTP()
    ScreenGui:Destroy()
end)

print("[Bread] MM2 TP Murderer chargé.")
