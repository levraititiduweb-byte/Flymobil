-- Gamepass Sniper (Custom UI) by Bread
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local HookActive = false
local HookedGamepasses = 0

-- ===== INTERFACE GRAPHIQUE (Custom) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadGamepassSniper"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
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
Title.Text = "Gamepass Sniper"
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
ToggleBtn.Position = UDim2.new(0, 10, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Activer le Hook: OFF"
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
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 95)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Statut: En attente..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DU HOOK =====
local function EnableHook()
    HookActive = true
    StatusLabel.Text = "Statut: Hook activé !\nEn attente de Gamepasses..."
    
    -- Hook de la fonction officielle de Roblox
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if HookActive and (method == "UserOwnsGamePassAsync" or method == "UserOwnsAssetAsync") then
            HookedGamepasses = HookedGamepasses + 1
            StatusLabel.Text = "Statut: Hook Actif !\nGamepasses Hookées: " .. HookedGamepasses
            return true -- On dit "Oui" au jeu
        end
        return oldNamecall(self, ...)
    end)
end

-- ===== GESTION DU BOUTON =====
local touchStartPos = nil
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchStartPos = input.Position
    end
end)

ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if touchStartPos and (input.Position - touchStartPos).Magnitude < 15 then
            if not HookActive then
                ToggleBtn.Text = "Activer le Hook: ON"
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                EnableHook()
            else
                HookActive = false
                ToggleBtn.Text = "Activer le Hook: OFF"
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                StatusLabel.Text = "Statut: Désactivé."
            end
        end
        touchStartPos = nil
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
