-- Ultimate Prison Life Hub V3 (Fixed) by Bread
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _G = {
    SilentAim = false,
    Aimbot = false,
    Noclip = false,
    Invisible = false,
    InfJump = false,
    FreeCam = false,
    ESP = false,
    Speed = 16,
    TargetPart = "Head"
}

-- ===== FONCTIONS DE CIBLAGE =====
local function isEnemy(player)
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getClosestPlayer()
    local closestDist = math.huge
    local closestPlayer = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) and isEnemy(p) then
            local targetPart = p.Character[_G.TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist and dist < 300 then
                    closestDist = dist
                    closestPlayer = p
                end
            end
        end
    end
    return closestPlayer
end

-- ===== LOGIQUE SILENT AIM (Fix pour ne pas casser le pistolet) =====
-- On ne touche plus au Raycast. On hook juste la position de la souris.
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    if _G.SilentAim and self == Mouse then
        if key == "Hit" or key == "Target" then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(_G.TargetPart) then
                if key == "Hit" then
                    return CFrame.new(target.Character[_G.TargetPart].Position)
                else
                    return target.Character[_G.TargetPart]
                end
            end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

-- ===== LOGIQUE AIMBOT (Caméra) =====
RunService.RenderStepped:Connect(function()
    if _G.Aimbot then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(_G.TargetPart) then
            local targetPos = target.Character[_G.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.2)
        end
    end
end)

-- ===== LOGIQUE NOCLIP (Fix avec Heartbeat) =====
RunService.Heartbeat:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- ===== LOGIQUE INVISIBLE & FREE CAM =====
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if _G.Invisible then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.LocalTransparencyModifier = 1
            end
        end
    end
end)

local freeCamConnection
local function toggleFreeCam(state)
    if state then
        freeCamConnection = RunService.RenderStepped:Connect(function()
            Camera.CameraType = Enum.CameraType.Scriptable
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    Camera.CFrame = Camera.CFrame + (moveDir * 2)
                end
            end
        end)
    else
        if freeCamConnection then freeCamConnection:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end

-- ===== LOGIQUE INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ===== LOGIQUE ESP =====
local ESPHighlights = {}
local function updateESP()
    for _, hl in pairs(ESPHighlights) do if hl then hl:Destroy() end end
    ESPHighlights = {}

    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and isEnemy(p) then
                local hl = Instance.new("Highlight")
                hl.Adornee = p.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = game:GetService("CoreGui")
                table.insert(ESPHighlights, hl)
            end
        end
    end
end

-- ===== INTERFACE RAYFIELD =====
local Window = Rayfield:CreateWindow({
    Name = "Bread Hub | Prison Life V3",
    LoadingTitle = "Chargement du Hub...",
    LoadingSubtitle = "by Bread",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Assistance de visée (Ennemis uniquement)")

CombatTab:CreateToggle({
    Name = "Silent Aim (Tire à travers les murs)",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value) _G.SilentAim = Value end
})

CombatTab:CreateToggle({
    Name = "Aimbot (Caméra)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value) _G.Aimbot = Value end
})

CombatTab:CreateDropdown({
    Name = "Partie visée",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "TargetPartDropdown",
    Callback = function(Option) _G.TargetPart = Option[1] end
})

local PlayerTab = Window:CreateTab("Joueur", 4483362458)
PlayerTab:CreateSection("Capacités")

PlayerTab:CreateToggle({
    Name = "Noclip (Traverser les murs)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value) 
        _G.Noclip = Value
        if not Value and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Invisible Mode (Local)",
    CurrentValue = false,
    Flag = "InvisibleToggle",
    Callback = function(Value) 
        _G.Invisible = Value
        if not Value and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump (Saut Infini)",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value) _G.InfJump = Value end
})

PlayerTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, 150},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        _G.Speed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

local VisualTab = Window:CreateTab("Visuel", 4483362458)
VisualTab:CreateSection("Visualisation & Caméra")

VisualTab:CreateToggle({
    Name = "ESP Joueurs (Rouge)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        _G.ESP = Value
        updateESP()
        task.spawn(function()
            while _G.ESP do
                task.wait(2)
                updateESP()
            end
        end)
    end
})

VisualTab:CreateToggle({
    Name = "Free Cam (Caméra détachée)",
    CurrentValue = false,
    Flag = "FreeCamToggle",
    Callback = function(Value)
        _G.FreeCam = Value
        toggleFreeCam(Value)
    end
})

Rayfield:Notify({
    Title = "Bread Hub V3",
    Content = "Script fixé ! Tu peux tirer normalement.",
    Duration = 5,
    Image = 4483362458,
})
