-- Ultimate Prison Life Hub (Rayfield) by Bread
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables d'état
local _G = {
    SilentAim = false,
    Aimbot = false,
    Noclip = false,
    ESP = false,
    Speed = 16,
    TargetPart = "Head"
}

-- ===== FONCTIONS UTILITAIRES =====
local function getClosestPlayer()
    local closestDist = math.huge
    local closestPlayer = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local targetPart = p.Character[_G.TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                -- On cherche la cible la plus proche du curseur (dans un rayon de 300 pixels)
                if dist < closestDist and dist < 300 then
                    closestDist = dist
                    closestPlayer = p
                end
            end
        end
    end
    return closestPlayer
end

-- ===== LOGIQUE SILENT AIM =====
-- On hook la métaméthode de la souris pour rediriger la position "Hit" vers la tête du joueur
local oldIndex
pcall(function()
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if _G.SilentAim and self == Mouse then
            if key == "Hit" or key == "Target" then
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild(_G.TargetPart) then
                    local targetPos = target.Character[_G.TargetPart].Position
                    if key == "Hit" then
                        return CFrame.new(targetPos)
                    elseif key == "Target" then
                        return target.Character[_G.TargetPart]
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
end)

-- ===== LOGIQUE AIMBOT (Caméra) =====
RunService.RenderStepped:Connect(function()
    if _G.Aimbot then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(_G.TargetPart) then
            local targetPos = target.Character[_G.TargetPart].Position
            -- On smooth la caméra vers la cible
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.2)
        end
    end
end)

-- ===== LOGIQUE NOCLIP =====
RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- ===== LOGIQUE ESP =====
local ESPHighlights = {}
local function updateESP()
    -- Nettoyage
    for _, hl in pairs(ESPHighlights) do if hl then hl:Destroy() end end
    ESPHighlights = {}

    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
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
    Name = "Bread Hub | Prison Life",
    LoadingTitle = "Chargement du Hub...",
    LoadingSubtitle = "by Bread",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- Onglet Combat
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Assistance de visée")

CombatTab:CreateToggle({
    Name = "Silent Aim (Tire à travers les murs)",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        _G.SilentAim = Value
    end
})

CombatTab:CreateToggle({
    Name = "Aimbot (Caméra)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        _G.Aimbot = Value
    end
})

CombatTab:CreateDropdown({
    Name = "Partie visée",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "TargetPartDropdown",
    Callback = function(Option)
        _G.TargetPart = Option[1]
    end
})

-- Onglet Mouvement
local MoveTab = Window:CreateTab("Mouvement", 4483362458)
MoveTab:CreateSection("Déplacements")

MoveTab:CreateToggle({
    Name = "Noclip (Traverser les murs)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        _G.Noclip = Value
    end
})

MoveTab:CreateSlider({
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

-- Onglet Visuel
local VisualTab = Window:CreateTab("Visuel", 4483362458)
VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
    Name = "ESP Joueurs (Rouge)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        _G.ESP = Value
        updateESP()
        -- Mise à jour périodique au cas où de nouveaux joueurs rejoignent
        task.spawn(function()
            while _G.ESP do
                task.wait(2)
                updateESP()
            end
        end)
    end
})

-- Message de fin
Rayfield:Notify({
    Title = "Bread Hub",
    Content = "Script chargé avec succès !",
    Duration = 5,
    Image = 4483362458,
})
