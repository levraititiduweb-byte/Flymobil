-- Ultimate Ability Wars Hub V2 (Hitbox Others + Real Kill Aura) by Bread
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _G = {
    HitboxOthers = false,
    SpeedBoost = false,
    InfJump = false,
    KillAura = false,
    AutoFarm = false,
    Invisible = false,
    AntiRagdoll = false,
    ESP = false,
    SpeedValue = 50,
    HitboxSize = 10,
    AuraRange = 20
}

-- ===== 1. AGRANDIR L'HITBOX DES AUTRES =====
RunService.Heartbeat:Connect(function()
    if _G.HitboxOthers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                        -- On agrandit les membres pour que les attaques touchent plus facilement
                        v.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                        v.Transparency = 0.5 -- Petit effet visuel pour voir l'hitbox
                        v.CanCollide = false -- Évite de bloquer le joueur dans les murs
                    end
                end
            end
        end
    end
end)

-- ===== 2. SPEED BOOST & INF JUMP & INVISIBLE & ANTI-RAGDOLL =====
local function applySpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.SpeedBoost and _G.SpeedValue or 16
    end
end

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        if _G.Invisible then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then v.LocalTransparencyModifier = 1 end
            end
        end
        if _G.AntiRagdoll then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)

-- ===== 3. KILL AURA (Clic Spam + Auto Aim) =====
local function getClosestEnemy()
    local closestDist = math.huge
    local closestPlayer = nil
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = p.Character.HumanoidRootPart
            local dist = (targetHRP.Position - myHRP.Position).Magnitude
            if dist <= _G.AuraRange and dist < closestDist then
                closestDist = dist
                closestPlayer = p
            end
        end
    end
    return closestPlayer
end

RunService.Heartbeat:Connect(function()
    if _G.KillAura then
        local target = getClosestEnemy()
        if target then
            local targetHRP = target.Character.HumanoidRootPart
            -- 1. On oriente la caméra vers l'ennemi
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
            -- 2. On spam le clic gauche (Attaque)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                task.wait(0.05) -- Petite pause pour ne pas faire crasher
                VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
            end)
        end
    end
end)

-- ===== 4. AUTO FARM (Similaire au Kill Aura mais pour farmer) =====
RunService.Heartbeat:Connect(function()
    if _G.AutoFarm and not _G.KillAura then
        local target = getClosestEnemy() -- Il utilise la même détection
        if target then
            local targetHRP = target.Character.HumanoidRootPart
            -- On se déplace vers la cible
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid:MoveTo(targetHRP.Position)
            end
            -- On attaque
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
            end)
        end
    end
end)

-- ===== 5. ESP =====
local ESPHighlights = {}
local function updateESP()
    for _, hl in pairs(ESPHighlights) do if hl then hl:Destroy() end end
    ESPHighlights = {}
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight")
                hl.Adornee = p.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.Parent = game:GetService("CoreGui")
                table.insert(ESPHighlights, hl)
            end
        end
    end
end

-- ===== INTERFACE RAYFIELD =====
local Window = Rayfield:CreateWindow({
    Name = "Bread Hub | Ability Wars V2",
    LoadingTitle = "Chargement du Hub...",
    LoadingSubtitle = "by Bread",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Combat & Hitbox")

CombatTab:CreateToggle({
    Name = "Agrandir l'Hitbox des Autres",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value) _G.HitboxOthers = Value end
})

CombatTab:CreateSlider({
    Name = "Taille de l'Hitbox",
    Range = {5, 30},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "HitboxSlider",
    Callback = function(Value) _G.HitboxSize = Value end
})

CombatTab:CreateToggle({
    Name = "Kill Aura (Clic Spam)",
    CurrentValue = false,
    Flag = "KillAuraToggle",
    Callback = function(Value) _G.KillAura = Value end
})

CombatTab:CreateSlider({
    Name = "Portée de l'Aura",
    Range = {10, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 20,
    Flag = "AuraSlider",
    Callback = function(Value) _G.AuraRange = Value end
})

CombatTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value) _G.AutoFarm = Value end
})

local PlayerTab = Window:CreateTab("Joueur", 4483362458)
PlayerTab:CreateSection("Mouvement & Survie")

PlayerTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value) _G.SpeedBoost = Value applySpeed() end
})

PlayerTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(Value) _G.SpeedValue = Value applySpeed() end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value) _G.InfJump = Value end
})

PlayerTab:CreateToggle({
    Name = "Anti-Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdollToggle",
    Callback = function(Value) _G.AntiRagdoll = Value end
})

PlayerTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "InvisibleToggle",
    Callback = function(Value) _G.Invisible = Value end
})

local MiscTab = Window:CreateTab("Divers", 4483362458)
MiscTab:CreateToggle({
    Name = "ESP Joueurs",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        _G.ESP = Value
        updateESP()
        task.spawn(function()
            while _G.ESP do task.wait(2) updateESP() end
        end)
    end
})

Rayfield:Notify({
    Title = "Bread Hub V2",
    Content = "Hitbox des autres et Kill Aura fixés !",
    Duration = 5,
    Image = 4483362458,
})
