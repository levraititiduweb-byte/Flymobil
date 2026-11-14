-- Auto Eat Blobs (Safe Mode) by Bread
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
MainFrame.Size = UDim2.new(0, 240, 0, 140)
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
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: En attente..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DU SCRIPT =====

-- Fonction pour trouver la taille d'un personnage/objet
local function getEntitySize(character)
    if not character then return 0 end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    -- 1. On cherche une valeur "Mass", "Size", "Level" ou "Score" dans le personnage
    for _, child in pairs(character:GetDescendants()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            local name = child.Name:lower()
            if name:find("mass") or name:find("size") or name:find("score") or name:find("level") then
                return child.Value
            end
        end
    end
    
    -- 2. Si on ne trouve pas, on utilise la taille physique du personnage
    return hrp.Size.X * hrp.Size.Y * hrp.Size.Z
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
        local minDistance = math.huge

        -- On scanne tous les joueurs du serveur
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local targetSize = getEntitySize(player.Character)
                    
                    -- LOGIQUE : On cible uniquement si le joueur est plus petit que nous
                    if targetSize < mySize * 0.9 then -- 0.9 = marge de sécurité de 10%
                        local distance = (myHRP.Position - targetHRP.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            bestTarget = targetHRP
                        end
                    end
                end
            end
        end

        -- Si on n'a pas trouvé de joueur plus petit, on cherche les "Blobs" (Boules de nourriture)
        if not bestTarget then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Part") or obj:IsA("Model") then
                    local targetHRP = obj:FindFirstChild("HumanoidRootPart") or (obj:IsA("Part") and obj) or obj:FindFirstChildWhichIsA("BasePart")
                    if targetHRP then
                        local targetSize = getEntitySize(obj)
                        -- Les blobs sont généralement fixes, on utilise une petite taille par défaut si introuvable
                        if targetSize == 0 then targetSize = 1 end 
                        
                        if targetSize < mySize * 0.9 then
                            local distance = (myHRP.Position - targetHRP.Position).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                bestTarget = targetHRP
                            end
                        end
                    end
                end
            end
        end

        -- Si on a trouvé une cible plus petite, on s'y téléporte
        if bestTarget then
            StatusLabel.Text = "Status: Mange une cible..."
            myHRP.CFrame = CFrame.new(bestTarget.Position)
            task.wait(0.1) -- Petit délai pour éviter le kick anti-tp
        else
            StatusLabel.Text = "Status: Aucune cible plus petite trouvée."
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
