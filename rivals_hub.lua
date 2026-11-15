-- Ultimate RIVALS Hub V4 (Blindé) by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Notification de test pour voir si le script s'exécute
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Bread",
    Text = "Script RIVALS en cours de chargement...",
    Duration = 3
})

local _G = {
    SilentAim = false,
    ESP = false,
    Speed = false,
    TriggerBot = false,
    SlideBoost = false,
    SpeedValue = 30,
    SlideForce = 120,
    MaxDistance = 150
}

local ESPObjects = {}

-- ===== BLINDAGE DE L'INTERFACE =====
local success, err = pcall(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BreadRivalsV4"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 260, 0, 290)
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
    Title.Text = "Bread | RIVALS V4"
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

    local SilentAimBtn = createBtn("Silent Aim: OFF", 40)
    local TriggerBotBtn = createBtn("Trigger Bot: OFF", 85)
    local ESPBtn = createBtn("ESP (Nom + Vie): OFF", 130)
    local SpeedBtn = createBtn("Speed Boost: OFF", 175)
    local SlideBtn = createBtn("Slide Boost: OFF", 220)
    local SkinBtn = createBtn("Changer Skin d'Arme", 265, Color3.fromRGB(100, 50, 150))

    -- ===== LOGIQUE SILENT AIM =====
    local function getClosestPlayer()
        local closestDist = math.huge
        local closestPlayer = nil
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local targetHead = p.Character.Head
                local dist3D = (targetHead.Position - myHRP.Position).Magnitude
                if dist3D <= _G.MaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist2D < closestDist and dist2D < 250 then
                            closestDist = dist2D
                            closestPlayer = p
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if _G.SilentAim and self == Mouse then
            if key == "Hit" or key == "Target" then
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    if key == "Hit" then
                        return CFrame.new(target.Character.Head.Position)
                    else
                        return target.Character.Head
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)

    -- ===== TRIGGER BOT =====
    RunService.RenderStepped:Connect(function()
        if _G.TriggerBot then
            local target = getClosestPlayer()
            if target then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                end)
            end
        end
    end)

    -- ===== ESP =====
    RunService.RenderStepped:Connect(function()
        if _G.ESP then
            for _, obj in pairs(ESPObjects) do if obj then obj:Destroy() end end
            ESPObjects = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local health = p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health or 0
                        local espLabel = Instance.new("TextLabel")
                        espLabel.Size = UDim2.new(0, 100, 0, 30)
                        espLabel.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 40)
                        espLabel.BackgroundTransparency = 1
                        espLabel.Text = p.Name .. "\nVie: " .. math.floor(health)
                        espLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        espLabel.TextSize = 12
                        espLabel.Font = Enum.Font.GothamBold
                        espLabel.Parent = ScreenGui
                        table.insert(ESPObjects, espLabel)
                    end
                end
            end
        end
    end)

    -- ===== SPEED & SLIDE =====
    RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                if _G.Speed then
                    if hum.MoveDirection.Magnitude > 0 then
                        hum.WalkSpeed = _G.SpeedValue
                    else
                        hum.WalkSpeed = 16
                    end
                end
                if _G.SlideBoost then
                    if hrp.Velocity.Magnitude > 20 and hum:GetState() == Enum.HumanoidStateType.Running then
                        hrp.Velocity = hrp.Velocity + (Camera.CFrame.LookVector * (_G.SlideForce / 10))
                    end
                end
            end
        end
    end)

    -- ===== SKIN CHANGER =====
    SkinBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 215, 0)
                        part.Material = Enum.Material.Neon
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

    bindToggle(SilentAimBtn, function(v) if v ~= nil then _G.SilentAim = v end return _G.SilentAim end, "Silent Aim: ON", "Silent Aim: OFF")
    bindToggle(TriggerBotBtn, function(v) if v ~= nil then _G.TriggerBot = v end return _G.TriggerBot end, "Trigger Bot: ON", "Trigger Bot: OFF")
    bindToggle(ESPBtn, function(v) if v ~= nil then _G.ESP = v end return _G.ESP end, "ESP (Nom + Vie): ON", "ESP (Nom + Vie): OFF")
    bindToggle(SpeedBtn, function(v) if v ~= nil then _G.Speed = v end return _G.Speed end, "Speed Boost: ON", "Speed Boost: OFF")
    bindToggle(SlideBtn, function(v) if v ~= nil then _G.SlideBoost = v end return _G.SlideBoost end, "Slide Boost: ON", "Slide Boost: OFF")

    CloseBtn.MouseButton1Click:Connect(function()
        for _, obj in pairs(ESPObjects) do if obj then obj:Destroy() end end
        ScreenGui:Destroy()
    end)
end)

if success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bread",
        Text = "Menu RIVALS chargé avec succès !",
        Duration = 3
    })
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bread - ERREUR",
        Text = "Erreur : " .. tostring(err),
        Duration = 10
    })
end 
