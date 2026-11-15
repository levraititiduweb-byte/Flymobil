-- Ultimate Blob Game GUI (Anti-Kick) by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local SpeedEnabled = false
local ESPEnabled = false
local AutoFarmEnabled = false
local GodModeEnabled = false
local WalkSpeedValue = 100

local Connections = {}
local Highlights = {}

-- ===== INTERFACE GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadBlobMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0, 20, 0, 60)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
Title.Text = "Bread Blob GUI"
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

-- Création des boutons
local function createBtn(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = MainFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local FarmBtn = createBtn("Safe Auto-Farm: OFF", 40)
local ESPBtn = createBtn("ESP (Voir Tailles): OFF", 85)
local GodBtn = createBtn("God Mode: OFF", 130)
local SpeedBtn = createBtn("Speed Boost: OFF", 175)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 215)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Vitesse: 100"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(1, -20, 0, 14)
SpeedSlider.Position = UDim2.new(0, 10, 0, 240)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedSlider.Text = ""
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Parent = MainFrame
local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SpeedSlider

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 265)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Prêt.\nLes joueurs plus petits sont en VERT.\nLes plus gros sont en ROUGE."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DE TAILLE =====
-- Détecte la taille approximative via le personnage
local function getPlayerSize(character)
    if not character then return 1 end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Size.X * hrp.Size.Y * hrp.Size.Z
    end
    return 1
end

-- ===== LOGIQUE ESP =====
local function clearESP()
    for _, hl in pairs(Highlights) do
        if hl then hl:Destroy() end
    end
    Highlights = {}
end

local function updateESP()
    if not ESPEnabled then return end
    clearESP()
    
    local mySize = getPlayerSize(LocalPlayer.Character)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local targetSize = getPlayerSize(p.Character)
            local hl = Instance.new("Highlight")
            hl.Adornee = p.Character
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            
            -- Vert si plus petit, Rouge si plus gros
            if targetSize < mySize then
                hl.FillColor = Color3.fromRGB(0, 255, 0)
            else
                hl.FillColor = Color3.fromRGB(255, 0, 0)
            end
            
            hl.Parent = ScreenGui
            table.insert(Highlights, hl)
        end
    end
end

local ESPConnection = RunService.Heartbeat:Connect(function()
    if ESPEnabled and tick() % 2 < 0.1 then
        updateESP()
    end
end)
table.insert(Connections, ESPConnection)

-- ===== LOGIQUE SAFE AUTO FARM (Pas de TP) =====
local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if SpeedEnabled or AutoFarmEnabled then
                hum.WalkSpeed = WalkSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end
end

local FarmConnection = RunService.Heartbeat:Connect(function()
    if not AutoFarmEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local mySize = getPlayerSize(char)
    local targetPos = nil

    -- 1. Chercher un joueur plus petit
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local tSize = getPlayerSize(p.Character)
                if tSize < mySize * 0.95 then
                    targetPos = tHRP.Position
                    StatusLabel.Text = "Status: Chasse de " .. p.Name
                    break
                end
            end
        end
    end

    -- 2. Si pas de joueur, chercher les blobs au sol
    if not targetPos then
        for _, obj in pairs(Workspace:GetChildren()) do
            if (obj:IsA("Part") or obj:IsA("Model")) and obj ~= char then
                local name = obj.Name:lower()
                if name:find("blob") or name:find("food") or name:find("pellet") then
                    if obj:IsA("Part") then
                        targetPos = obj.Position
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        targetPos = obj.PrimaryPart.Position
                    end
                    if targetPos then
                        StatusLabel.Text = "Status: Mange un blob..."
                        break
                    end
                end
            end
        end
    end

    -- 3. Utiliser MoveTo (Glisser vers la cible au lieu de TP)
    if targetPos then
        hum:MoveTo(targetPos)
    else
        StatusLabel.Text = "Status: Aucune cible trouvée."
    end
end)
table.insert(Connections, FarmConnection)

-- ===== LOGIQUE GOD MODE =====
local GodConnection = RunService.Heartbeat:Connect(function()
    if GodModeEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
        end
    end
end)
table.insert(Connections, GodConnection)

-- ===== GESTION DES BOUTONS =====
local function bindToggle(btn, stateBool, onText, offText, callback)
    local touchStartPos = nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            touchStartPos = input.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if touchStartPos and (input.Position - touchStartPos).Magnitude < 15 then
                if stateBool() then
                    btn.Text = offText
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                else
                    btn.Text = onText
                    btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                end
                stateBool(not stateBool())
                if callback then callback() end
            end
            touchStartPos = nil
        end
    end)
end

bindToggle(FarmBtn, function(v) if v ~= nil then AutoFarmEnabled = v end return AutoFarmEnabled end, "Safe Auto-Farm: ON", "Safe Auto-Farm: OFF", applySpeed)
bindToggle(ESPBtn, function(v) if v ~= nil then ESPEnabled = v; if not v then clearESP() end end return ESPEnabled end, "ESP (Voir Tailles): ON", "ESP (Voir Tailles): OFF")
bindToggle(GodBtn, function(v) if v ~= nil then GodModeEnabled = v end return GodModeEnabled end, "God Mode: ON", "God Mode: OFF")
bindToggle(SpeedBtn, function(v) if v ~= nil then SpeedEnabled = v end return SpeedEnabled end, "Speed Boost: ON", "Speed Boost: OFF", applySpeed)

-- Slider Vitesse
local dragging = false
SpeedSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relX = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        WalkSpeedValue = math.floor(relX * 150) + 50
        SpeedLabel.Text = "Vitesse: " .. WalkSpeedValue
        applySpeed()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)

CloseBtn.MouseButton1Click:Connect(function()
    AutoFarmEnabled = false
    ESPEnabled = false
    GodModeEnabled = false
    SpeedEnabled = false
    clearESP()
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    ScreenGui:Destroy()
end)
