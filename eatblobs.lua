-- God Mode & Speed Boost by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local GodModeEnabled = false
local SpeedEnabled = false
local SpeedValue = 100
local GodConnection = nil

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadGodMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200)
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
Title.Text = "Bread God & Speed"
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

-- Bouton GodMode
local GodBtn = Instance.new("TextButton")
GodBtn.Size = UDim2.new(1, -20, 0, 42)
GodBtn.Position = UDim2.new(0, 10, 0, 38)
GodBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GodBtn.Text = "God Mode: OFF"
GodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GodBtn.TextSize = 15
GodBtn.Font = Enum.Font.GothamBold
GodBtn.BorderSizePixel = 0
GodBtn.AutoButtonColor = false
GodBtn.Parent = MainFrame

local GodCorner = Instance.new("UICorner")
GodCorner.CornerRadius = UDim.new(0, 6)
GodCorner.Parent = GodBtn

-- Bouton Speed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 42)
SpeedBtn.Position = UDim2.new(0, 10, 0, 88)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "Speed Boost: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 15
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.BorderSizePixel = 0
SpeedBtn.AutoButtonColor = false
SpeedBtn.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBtn

-- Slider Vitesse
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 140)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Vitesse: " .. SpeedValue
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(1, -20, 0, 14)
SpeedSlider.Position = UDim2.new(0, 10, 0, 165)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedSlider.Text = ""
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SpeedSlider

-- ===== LOGIQUE GOD MODE =====
local function applyGodMode()
    if GodConnection then GodConnection:Disconnect() end
    
    if GodModeEnabled then
        GodConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
        end)
    end
end

-- ===== LOGIQUE SPEED BOOST =====
local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if SpeedEnabled then
                humanoid.WalkSpeed = SpeedValue
            else
                humanoid.WalkSpeed = 16 -- Vitesse par défaut de Roblox
            end
        end
    end
end

-- ===== GESTION DES BOUTONS =====
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

bindButton(GodBtn, function()
    GodModeEnabled = not GodModeEnabled
    if GodModeEnabled then
        GodBtn.Text = "God Mode: ON"
        GodBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        GodBtn.Text = "God Mode: OFF"
        GodBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 100 end
        end
    end
    applyGodMode()
end)

bindButton(SpeedBtn, function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedBtn.Text = "Speed Boost: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        SpeedBtn.Text = "Speed Boost: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    applySpeed()
end)

CloseBtn.MouseButton1Click:Connect(function()
    if GodConnection then GodConnection:Disconnect() end
    ScreenGui:Destroy()
end)

-- Slider Vitesse Drag
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

-- Réappliquer si on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyGodMode()
    applySpeed()
end)

print("[Bread] God Mode & Speed chargé.")
