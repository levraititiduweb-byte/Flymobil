-- Gamepass Signal Spoofer by Bread
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreadSignalSpoof"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
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
Title.Text = "Signal Spoofer (Gamepass)"
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

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 42)
ScanBtn.Position = UDim2.new(0, 10, 0, 38)
ScanBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ScanBtn.Text = "Envoyer Faux Signaux"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.TextSize = 15
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.BorderSizePixel = 0
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = MainFrame
local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Prêt. Prêt à scanner les signaux réseau."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- ===== LOGIQUE DE SCAN =====
local function FireFakeSignals()
    StatusLabel.Text = "Status: Scan des RemoteEvents en cours..."
    task.wait(0.5)

    local firedCount = 0
    local keywords = {"buy", "purchase", "gamepass", "premium", "vip", "donate", "robux"}
    
    -- On scanne ReplicatedStorage ET Workspace pour trouver les RemoteEvents cachés
    local function scanFolder(folder)
        for _, obj in pairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local objName = obj.Name:lower()
                
                -- On vérifie si le nom du signal correspond à un achat
                for _, keyword in pairs(keywords) do
                    if objName:find(keyword) then
                        StatusLabel.Text = "Status: Signal trouvé -> " .. obj.Name
                        
                        -- On tire sur le signal (FireServer)
                        pcall(function()
                            if obj:IsA("RemoteEvent") then
                                -- On envoie l'ID du joueur ou un ID de gamepass au hasard
                                obj:FireServer(LocalPlayer.UserId)
                                obj:FireServer(1) -- Faux ID de gamepass
                            elseif obj:IsA("RemoteFunction") then
                                obj:InvokeServer(LocalPlayer.UserId)
                            end
                        end)
                        firedCount += 1
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end

    scanFolder(game:GetService("ReplicatedStorage"))
    scanFolder(game:GetService("Workspace"))
    
    if firedCount > 0 then
        StatusLabel.Text = "Status: " .. firedCount .. " signaux envoyés au serveur !"
    else
        StatusLabel.Text = "Status: Aucun signal d'achat trouvé sur ce jeu."
    end
end

ScanBtn.MouseButton1Click:Connect(function()
    FireFakeSignals()
end)

ScanBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        FireFakeSignals()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
