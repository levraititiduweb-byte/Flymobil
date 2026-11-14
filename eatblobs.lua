-- Auto Eat Smaller Players (Debug Edition) by Bread
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local AutoFarmEnabled = false
local FarmConnection = nil

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadBlobFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
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
Title.Text = "Bread Blob Farmer"
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
ToggleBtn.Position = UDim2.new(0, 10, 0, 38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Auto Farm: OFF"
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
StatusLabel.Size = UDim2.new(1, -20, 0, 45)
StatusLabel.Position = UDim2.new(0, 10, 0, 85)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: En attente...\nMa Taille: ? | Cible: ?"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DU SCRIPT =====

-- Fonction améliorée pour trouver la taille (Mass, Size, Level, Scale)
local function getEntitySize(character)
    if not character then return 0 end
    
    -- 1. Chercher dans les Leaderstats (Très courant)
    local leaderstats = character:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            local name = stat.Name:lower()
            if name:find("size") or name:find("mass") or name:find("level") or name:find("score") or name:find("weight") then
                return tonumber(stat.Value) or 0
            end
        end
    end

    -- 2. Chercher les BodyScales (Taille du personnage Roblox)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local scale = 1
        if humanoid:FindFirstChild("BodyDepthScale") then scale *= humanoid.BodyDepthScale.Value end
        if humanoid:FindFirstChild("BodyWidthScale") then scale *= humanoid.BodyWidthScale.Value end
        if humanoid:FindFirstChild("BodyHeightScale") then scale *= humanoid.BodyHeightScale.Value end
        if scale ~= 1 then return scale * 10 end -- Multiplié pour avoir un chiffre plus grand
    end

    -- 3. En dernier recours, la taille physique
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Size.X * hrp.Size.Y * hrp.Size.Z
    end
    
    return 0
end

local function startFarm()
    if FarmConnection then return end
    ToggleBtn.Text = "Auto Farm: ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    FarmConnection = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local mySize = getEntitySize(myChar)
        local bestTarget = nil

        -- On scanne UNIQUEMENT les JOUEURS (pas les blobs au sol pour éviter le TP en l'air)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local targetSize = getEntitySize(player.Character)
                    
                    -- Si le joueur est plus petit (avec une petite marge)
                    if targetSize > 0 and targetSize < (mySize * 0.95) then
                        bestTarget = targetHRP
                        StatusLabel.Text = "Status: TP sur " .. player.Name .. "\nMa Taille: " .. math.floor(mySize) .. " | Cible: " .. math.floor(targetSize)
                        break -- On prend le premier joueur plus petit trouvé
                    end
                end
            end
        end

        -- Si on a trouvé un joueur plus petit, on se TP DIRECTEMENT DANS LUI
        if bestTarget then
            myHRP.CFrame = bestTarget.CFrame
            -- On force la vélocité à zéro pour ne pas glisser
            myHRP.Velocity = Vector3.new(0,0,0) 
        else
            StatusLabel.Text = "Status: Aucun joueur plus petit trouvé.\nMa Taille: " .. math.floor(mySize)
        end
    end)
end

local function stopFarm()
    if FarmConnection then
        FarmConnection:Disconnect()
        FarmConnection = nil
    end
    ToggleBtn.Text = "Auto Farm: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    StatusLabel.Text = "Status: Désactivé."
end

-- Gestion du bouton
local touchStartPos = nil
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchStartPos = input.Position
    end
end)

ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if touchStartPos and (input.Position - touchStartPos).Magnitude < 15 then
            if FarmConnection then stopFarm() else startFarm() end
        end
        touchStartPos = nil
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopFarm()
    ScreenGui:Destroy()
end)
