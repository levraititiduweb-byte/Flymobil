-- Visual Robux Spoofer by Bread
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local SpoofAmount = "999,999,999"
local SpoofActive = false
local SpoofConnection = nil

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadRobuxSpoof"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 160)
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
Title.Text = "Bread Robux Spoofer"
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

-- Input pour le montant
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -20, 0, 35)
TextBox.Position = UDim2.new(0, 10, 0, 38)
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.Gotham
TextBox.PlaceholderText = "Entre le montant (ex: 999999)"
TextBox.Text = "999,999,999"
TextBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

-- Bouton ON/OFF
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 42)
ToggleBtn.Position = UDim2.new(0, 10, 0, 85)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Spoof Robux: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- ===== LOGIQUE DU SCRIPT =====

local function spoofRobux()
    local coreGui = gethui and gethui() or game:GetService("CoreGui")
    
    -- On cherche l'interface du Topbar de Roblox
    for _, gui in pairs(coreGui:GetChildren()) do
        if gui.Name == "RobloxGui" or gui.Name == "TopbarApp" then
            for _, desc in pairs(gui:GetDescendants()) do
                -- On cherche les textes qui ressemblent à des nombres ou qui sont dans la zone du haut
                if desc:IsA("TextLabel") and desc.AbsolutePosition.Y < 100 then
                    -- Si le texte actuel est un nombre (ou contient des virgules)
                    if tonumber(desc.Text:gsub(",", "")) or desc.Text:match("^%d") then
                        -- Si ce n'est pas le nom du joueur ou autre, on remplace
                        desc.Text = SpoofAmount
                        desc.TextColor3 = Color3.fromRGB(0, 255, 100) -- Petite touche de couleur verte fluo
                    end
                end
            end
        end
    end
end

local function startSpoof()
    if SpoofConnection then return end
    ToggleBtn.Text = "Spoof Robux: ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    -- On boucle toutes les 0.1s pour garder le faux montant affiché (Roblox essaie de le remettre)
    SpoofConnection = RunService.Heartbeat:Connect(function()
        spoofRobux()
    end)
end

local function stopSpoof()
    if SpoofConnection then
        SpoofConnection:Disconnect()
        SpoofConnection = nil
    end
    ToggleBtn.Text = "Spoof Robux: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
            if SpoofConnection then stopSpoof() else startSpoof() end
        end
        touchStartPos = nil
    end
end)

-- Mettre à jour le montant quand on tape dans la case
TextBox.FocusLost:Connect(function()
    if TextBox.Text ~= "" then
        SpoofAmount = TextBox.Text
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopSpoof()
    ScreenGui:Destroy()
end)
