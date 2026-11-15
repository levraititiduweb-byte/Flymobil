-- Auto Gamepass Sniper & Hooker by Bread
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/Rayfield/main/source.lua'))()

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local HookedGamepasses = 0
local HookActive = false

-- Interface
local Window = Rayfield:CreateWindow({
    Name = "Bread | Gamepass Sniper",
    LoadingTitle = "Recherche de failles...",
    LoadingSubtitle = "by Bread",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Scanner", 4483362458)
MainTab:CreateSection("Analyse du jeu")

local StatusLabel = MainTab:CreateLabel("Statut: En attente du scan...")
local CountLabel = MainTab:CreateLabel("Gamepasses Hookées: 0")

-- ===== LOGIQUE DE HOOK =====
local function StartHook()
    HookActive = true
    StatusLabel:Set("Statut: Scan des scripts locaux en cours...")
    
    -- On utilise hookmetamethod pour intercepter TOUTES les demandes de Gamepass
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if HookActive and (method == "UserOwnsGamePassAsync" or method == "UserOwnsAssetAsync") then
            HookedGamepasses += 1
            CountLabel:Set("Gamepasses Hookées: " .. HookedGamepasses)
            return true -- On dit "Oui" au jeu
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- On scanne aussi les scripts pour trouver les ID (pour le fun)
    task.spawn(function()
        local countScripts = 0
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("LocalScript") then
                countScripts += 1
                if countScripts % 10 == 0 then
                    StatusLabel:Set("Statut: Analyse de " .. countScripts .. " scripts...")
                    task.wait()
                end
            end
        end
        StatusLabel:Set("Statut: Hook Actif ! Tu as les Gamepasses sur ce client.")
    end)
end

local function StopHook()
    HookActive = false
    StatusLabel:Set("Statut: Désactivé (Le jeu voit ton vrai inventaire).")
end

MainTab:CreateButton({
    Name = "Activer le Hook (Scan & Bypass)",
    Callback = function()
        StartHook()
    end
})

MainTab:CreateButton({
    Name = "Désactiver le Hook",
    Callback = function()
        StopHook()
    end
})

-- ===== BOUTON DE TEST =====
MainTab:CreateSection("Test de sécurité")
MainTab:CreateButton({
    Name = "Tester une Gamepass (ID au hasard)",
    Callback = function()
        local testId = 1234567 -- Remplacer par l'ID d'une Gamepass de ton jeu
        local owns = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, testId)
        if owns then
            StatusLabel:Set("Test: Le Hook dit OUI (Faille trouvée !)")
        else
            StatusLabel:Set("Test: Le jeu utilise le serveur (Sécurisé).")
        end
    end
})

Rayfield:Notify({
    Title = "Bread Gamepass Sniper",
    Content = "Prêt à scanner. Appuie sur 'Activer le Hook'.",
    Duration = 5,
    Image = 4483362458,
})
