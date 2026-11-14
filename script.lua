-- Fly GUI Menu Mobile (Utilise le Joystick Natif) by Bread
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local flying = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 50

local success, err = pcall(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BreadFlyMenuMobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ===== MENU PRINCIPAL =====
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 230, 0, 160)
    Main.Position = UDim2.new(0, 20, 0, 60)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Bread Fly Mobile"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 1)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Main
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 42)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 38)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = "Fly: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 16
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Main
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 88)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Vitesse: 50"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 14
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = Main

    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(1, -20, 0, 14)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 112)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Text = ""
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = Main
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SpeedSlider

    -- ===== BOUTONS MONTER/DESCENDRE (A droite) =====
    local ControlPanel = Instance.new("Frame")
    ControlPanel.Name = "ControlPanel"
    ControlPanel.Size = UDim2.new(0, 60, 0, 130)
    ControlPanel.Position = UDim2.new(1, -80, 1, -150) -- En bas à droite
    ControlPanel.BackgroundTransparency = 1
    ControlPanel.Visible = false
    ControlPanel.Parent = ScreenGui

    local function makeBtn(name, text, pos)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(1, 0, 0, 60)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.BackgroundTransparency = 0.2
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 24
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.Parent = ControlPanel
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = b
        return b
    end

    local btnAscend = makeBtn("Ascend", "+", UDim2.new(0, 0, 0, 0))
    local btnDescend = makeBtn("Descend", "-", UDim2.new(0, 0, 0, 70))

    -- ===== LOGIQUE FLY =====
    local verticalMove = 0

    local function stopFly()
        flying = false
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do
                    if v.Name == "BreadFlyBV" or v.Name == "BreadFlyBG" then v:Destroy() end
                end
            end
        end
        ToggleBtn.Text = "Fly: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ControlPanel.Visible = false
    end

    local function startFly()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        flying = true
        ToggleBtn.Text = "Fly: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        ControlPanel.Visible = true

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "BreadFlyBV"
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "BreadFlyBG"
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.P = 3000
        bodyGyro.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying then return end
            local c = LocalPlayer.Character
            if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart")
            if not root or not bodyVelocity or not bodyGyro then return end

            -- Astuce : Force le jeu à croire qu'on est au sol pour que le joystick natif marche
            humanoid:ChangeState(Enum.HumanoidStateType.Running)

            -- Récupère la direction du joystick natif (ou des touches ZQSD/WASD sur PC)
            local moveDir = humanoid.MoveDirection
            
            local finalMove = Vector3.zero
            
            -- Si on bouge avec le joystick
            if moveDir.Magnitude > 0 then
                finalMove = moveDir * flySpeed
            end

            -- Si on utilise les boutons + ou -
            if verticalMove ~= 0 then
                finalMove = finalMove + Vector3.new(0, verticalMove * flySpeed, 0)
            end

            bodyVelocity.Velocity = finalMove
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame -- La caméra reste droite
        end)
    end

    -- Boutons + et -
    local function bindAltitude(button, val)
        button.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
                verticalMove = val 
            end 
        end)
        button.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
                verticalMove = 0 
            end 
        end)
    end
    bindAltitude(btnAscend, 1)
    bindAltitude(btnDescend, -1)

    -- Bouton Fly ON/OFF
    ToggleBtn.MouseButton1Click:Connect(function() 
        if flying then stopFly() else startFly() end 
    end)
    ToggleBtn.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch then 
            if flying then stopFly() else startFly() end 
        end 
    end)

    -- Bouton Fermer
    CloseBtn.MouseButton1Click:Connect(function() stopFly() ScreenGui:Destroy() end)
    CloseBtn.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch then stopFly() ScreenGui:Destroy() end 
    end)

    -- Slider Vitesse
    local dragging = false
    SpeedSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
            flySpeed = math.floor(relX * 200) + 10
            SpeedLabel.Text = "Vitesse: " .. flySpeed
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function() if flying then stopFly() end end)
end)

if success then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Bread", Text = "Fly (Joystick Natif) charge !"})
else
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Bread - ERREUR", Text = tostring(err)})
end
