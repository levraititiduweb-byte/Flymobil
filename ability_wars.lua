-- Ultimate Ability Wars Hub (Rayfield) by Bread
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _G = {
    HitboxExpand = false,
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

-- ===== FONCTIONS UTILITAIRES =====
local function isEnemy(player)
    if player == LocalPlayer then return false end
    return true -- Ability Wars est souvent un free-for-all
end

-- ===== 1. AGRANDIR L'HITBOX =====
RunService.Heartbeat:Connect(function()
    if _G.HitboxExpand and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
            end
        end
    end
end)

-- ===== 2. SPEED BOOST =====
local function applySpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.SpeedBoost and _G.SpeedValue or 16
    end
end

-- ===== 3. INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ===== 4. KILL AURA =====
RunService.Heartbeat:Connect(function()
    if _G.KillAura and LocalPlayer.Character then
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, p in pairs(Players:GetPlayers()) do
                if isEnemy(p) and p.Character then
                    local targetHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and (targetHRP.Position - myHRP.Position).Magnitude <= _G.AuraRange then
                        -- Technique de Kill Aura : On envoie un signal de dégât
                        local args = {p.Character, 9999}
                        -- Le nom du RemoteEvent de dégât change souvent, on utilise une méthode générique
                        pcall(function()
                            game:GetService("ReplicatedStorage").Remotes.Damage:FireServer(p.Character, 9999)
                        end)
                    end
                end
            end
        end
    end
end)

-- ===== 5. AUTO FARM (Tape sur les ennemis proches) =====
RunService.Heartbeat:Connect(function()
    if _G.AutoFarm and LocalPlayer.Character then
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, p in pairs(Players:GetPlayers()) do
                if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = p.Character.HumanoidRootPart
                    if (targetHRP.Position - myHRP.Position).Magnitude < 50 then
                        -- On tourne la caméra vers la cible
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
                        -- On simule le clic gauche pour attaquer (si tu as une ability équipée)
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(Mouse.X, Mouse.Y))
                            task.wait(0.1)
                            VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y))
                        end)
                        break
                    end
                end
            end
        end
    end
end)

-- ===== 6. UNLOCK BADGE (Faux badges locaux) =====
local function fakeUnlockBadges()
    -- Ça affiche une notification "Badge obtenu" pour te faire plaisir
    -- (Le vrai badge n'est pas débloqué sur ton compte Roblox)
    for i = 1, 5 do
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Badge Obtenu !",
            Text = "Vous avez débloqué le badge secret " .. i .. " !",
            Duration = 3,
            Icon = "rbxassetid://123456789" -- Icône par défaut
        })
        task.wait(1)
    end
end

-- ===== 7. TELEPORT AU SPAWN =====
local function teleportToSpawn()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Remplace les coordonnées par celles du spawn de ton jeu
            hrp.CFrame = CFrame.new(0, 50, 0) 
        end
    end
end

-- ===== 8. INVISIBLE =====
RunService.Stepped:Connect(function()
    if _G.Invisible and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.LocalTransparencyModifier = 1
            end
        end
    end
end)

-- ===== 9. ANTI-RAGDOLL =====
RunService.Heartbeat:Connect(function()
    if _G.AntiRagdoll and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

-- ===== 10. ESP =====
local ESPHighlights = {}
local function updateESP()
    for _, hl in pairs(ESPHighlights) do if hl then hl:Destroy() end end
    ESPHighlights = {}

    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character then
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
    Name = "Bread Hub | Ability Wars",
    LoadingTitle = "Chargement du Hub...",
    LoadingSubtitle = "by Bread",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- Onglet Combat
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Combat & Hitbox")

CombatTab:CreateToggle({
    Name = "Agrandir l'Hitbox",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value) _G.HitboxExpand = Value end
})

CombatTab:CreateSlider({
    Name = "Taille de l'Hitbox",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "HitboxSlider",
    Callback = function(Value) _G.HitboxSize = Value end
})

CombatTab:CreateToggle({
    Name = "Kill Aura (Tue à proximité)",
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
    Name = "Auto Farm (Attaque auto)",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value) _G.AutoFarm = Value end
})

-- Onglet Joueur
local PlayerTab = Window:CreateTab("Joueur", 4483362458)
PlayerTab:CreateSection("Mouvement & Survie")

PlayerTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value) 
        _G.SpeedBoost = Value 
        applySpeed()
    end
})

PlayerTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(Value) 
        _G.SpeedValue = Value
        applySpeed()
    end
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

PlayerTab:CreateButton({
    Name = "Téléporter au Spawn",
    Callback = function() teleportToSpawn() end
})

-- Onglet Visuel & Divers
local MiscTab = Window:CreateTab("Divers", 4483362458)
MiscTab:CreateSection("Visuel & Badges")

MiscTab:CreateToggle({
    Name = "ESP Joueurs",
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

MiscTab:CreateButton({
    Name = "Débloquer les Badges (Visuel)",
    Callback = function() fakeUnlockBadges() end
})

Rayfield:Notify({
    Title = "Bread Hub",
    Content = "Hub Ability Wars chargé avec succès !",
    Duration = 5,
    Image = 4483362458,
})
