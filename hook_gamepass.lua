-- Ultimate Client Spoofer (Robux + Gamepass) by Bread
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local SpoofRobuxActive = false
local SpoofGamepassActive = false
local FakeRobuxAmount = "999,999,999"

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadUltimateSpoof"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220)
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
Title.Text = "Ultimate Client Spoofer"
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

local function createBtn(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = MainFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local GamepassBtn = createBtn("Hook Gamepass: OFF", 40)
local RobuxBtn = createBtn("Spoof Robux Visuel: OFF", 90)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 140)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Prêt."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE HOOK GAMEPASS =====
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if SpoofGamepassActive and method == "UserOwnsGamePassAsync" and self == MarketplaceService then
        return true -- Dit "Oui" au jeu sur ton écran
    end
    return oldNamecall(self, ...)
end)

-- ===== LOGIQUE SPOOF ROBUX =====
local RobuxConnection = RunService.Heartbeat:Connect(function()
    if SpoofRobuxActive then
        local coreGui = gethui and gethui() or game:GetService("CoreGui")
        for _, desc in pairs(coreGui:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local cleanText = desc.Text:gsub(",", ""):gsub(" ", "")
                if tonumber(cleanText) then
                    desc.Text = FakeRobuxAmount
                    desc.TextColor3 = Color3.fromRGB(0, 255, 100)
                end
            end
        end
    end
end)

-- ===== GESTION DES BOUTONS =====
local function bindToggle(btn, stateBool, onText, offText)
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
            end
            touchStartPos = nil
        end
    end)
end

bindToggle(GamepassBtn, function(v) if v ~= nil then SpoofGamepassActive = v end return SpoofGamepassActive end, "Hook Gamepass: ON", "Hook Gamepass: OFF")
bindToggle(RobuxBtn, function(v) if v ~= nil then SpoofRobuxActive = v end return SpoofRobuxActive end, "Spoof Robux Visuel: ON", "Spoof Robux Visuel: OFF")

CloseBtn.MouseButton1Click:Connect(function()
    RobuxConnection:Disconnect()
    ScreenGui:Destroy()
end)
