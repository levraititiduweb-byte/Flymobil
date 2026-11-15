-- Ultimate All-in-One Steal Script by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- États
local AutoStealEnabled = false
local GodModeEnabled = false
local SpeedEnabled = false
local ESPEnabled = false
local FlySpeed = 100
local SpeedValue = 100

local Connections = {}
local Highlights = {}

-- ===== INTERFACE GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadAllInOne"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 320)
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
Title.Text = "Bread Ultimate Menu"
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

-- Fonction pour créer les boutons
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

local StealBtn = createBtn("Auto Steal: OFF", 40)
local GodBtn = createBtn("God Mode: OFF", 85)
local ESPBtn = createBtn("ESP: OFF", 130)
local SpeedBtn = createBtn("Speed: OFF", 175)

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
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 265)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Prêt."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE GOD MODE =====
local oldIndex, oldNewIndex
pcall(function()
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if GodModeEnabled and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character and (key == "Health" or key == "MaxHealth") then
            return math.huge
        end
        return oldIndex(self, key)
    end)
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if GodModeEnabled and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character and (key == "Health" or key == "MaxHealth") then
            return
        end
        return oldNewIndex(self, key, value)
    end)
end)

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

-- ===== LOGIQUE SPEED =====
local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedEnabled and SpeedValue or 16
        end
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)

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
    
    -- ESP Joueurs
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = Instance.new("Highlight")
            hl.Adornee = p.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = ScreenGui
            table.insert(Highlights, hl)
        end
    end
    
    -- ESP Œufs (Scan de la map)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("brainrot") then
                local hl = Instance.new("Highlight")
                hl.Adornee = obj
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = ScreenGui
                table.insert(Highlights, hl)
            end
        end
    end
end

local ESPConnection = RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        -- On met à jour l'ESP toutes les 2 secondes pour éviter de lag
        if tick() % 2 < 0.1 then updateESP() end
    end
end)
table.insert(Connections, ESPConnection)

-- ===== LOGIQUE AUTO STEAL =====
local isHolding = false
local function holdClick()
    if not isHolding then
        isHolding = true
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0.5, 0.5), workspace.CurrentCamera.CFrame)
    end
end

local function releaseClick()
    if isHolding then
        isHolding = false
        VirtualUser:Button1Up(Vector2.new(0.5, 0.5), workspace.CurrentCamera.CFrame)
    end
end

local function getBestEgg()
    local bestEgg = nil
    local highestValue = -1
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("brainrot") then
                -- Essayer de lire le prix (Value/Price)
                local price = obj:FindFirstChild("Price") or obj:FindFirstChild("Value")
                local val = 0
                if price and (price:IsA("IntValue") or price:IsA("NumberValue")) then
                    val = price.Value
                else
                    val = math.random(1,100) -- Valeur au hasard si pas de prix
                end
                if val > highestValue then
                    highestValue = val
                    bestEgg = obj
                end
            end
        end
    end
    return bestEgg
end

local StealThread = task.spawn(function()
    while AutoStealEnabled do
        task.wait(0.1)
        local bestEgg = getBestEgg()
        local char = LocalPlayer.Character
        if char and bestEgg then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                StatusLabel.Text = "Status: Vol de " .. bestEgg.Name
                local pos = bestEgg:IsA("Model") and bestEgg:GetPivot().Position or bestEgg.Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.1)
                
                holdClick()
                task.wait(1.5) -- Temps de maintien pour voler
                releaseClick()
                
                StatusLabel.Text = "Status: Pause..."
                task.wait(1) -- Pause avant de recommencer
            end
        else
            StatusLabel.Text = "Status: Aucun œuf trouvé."
        end
    end
end)

-- ===== GESTION DES BOUTONS =====
local function bindToggle(btn, stateBool, onText, offText, colorOn)
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
                    btn.BackgroundColor3 = colorOn or Color3.fromRGB(50, 150, 50)
                end
                stateBool(not stateBool())
            end
            touchStartPos = nil
        end
    end)
end

-- On utilise des fonctions anonymes pour lire/écrire les états
bindToggle(StealBtn, function(v) if v ~= nil then AutoStealEnabled = v end return AutoStealEnabled end, "Auto Steal: ON", "Auto Steal: OFF")
bindToggle(GodBtn, function(v) if v ~= nil then GodModeEnabled = v end return GodModeEnabled end, "God Mode: ON", "God Mode: OFF")
bindToggle(ESPBtn, function(v) 
    if v ~= nil then 
        ESPEnabled = v 
        if not v then clearESP() end
    end 
    return ESPEnabled 
end, "ESP: ON", "ESP: OFF", Color3.fromRGB(50, 100, 200))
bindToggle(SpeedBtn, function(v) 
    if v ~= nil then 
        SpeedEnabled = v 
        applySpeed()
    end 
    return SpeedEnabled 
end, "Speed: ON", "Speed: OFF")

-- Slider Vitesse
local dragging = false
SpeedSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relX = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        SpeedValue = math.floor(relX * 200) + 16
        SpeedLabel.Text = "Vitesse: " .. SpeedValue
        if SpeedEnabled then applySpeed() end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Nettoyage
    AutoStealEnabled = false
    GodModeEnabled = false
    ESPEnabled = false
    clearESP()
    if isHolding then releaseClick() end
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    ScreenGui:Destroy()
end)

print("[Bread] Ultimate All-in-One chargé.")
