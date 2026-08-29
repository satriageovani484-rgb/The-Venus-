-- ============================================
-- SKTEAM PROJECT - Fly GUI V4 (FIXED)
-- Owner: The-Venus
-- Fixed by: Satriageovani484
-- Features: Fly, Noclip, WalkSpeed, Infinite Jump, ESP
-- ============================================

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- ===== VARIABEL UTAMA =====
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local jumpEnabled = false
local espEnabled = false

local flySpeed = 60
local walkSpeed = 32
local jumpPower = 70

local bodyVelocity = nil
local bodyGyro = nil
local moveDirection = Vector3.new(0,0,0)
local espObjects = {}
local noclipConnection = nil
local jumpConnection = nil
local menuVisible = true

-- ===== NOTIFY FUNCTION =====
local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 3;
        Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
    })
end

-- ===== FLY FUNCTION (DIPERBAIKI) =====
local function toggleFly(state)
    flyEnabled = state
    
    if state then
        -- Destroy existing instances
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        -- Create new BodyVelocity
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = rootPart
        
        -- Create new BodyGyro
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true
        notify("Fly", "✅ Fly Enabled")
    else
        -- Clean up
        if bodyVelocity then 
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then 
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        humanoid.PlatformStand = false
        moveDirection = Vector3.new(0,0,0)
        notify("Fly", "❌ Fly Disabled")
    end
end

-- ===== NOCLIP FUNCTION =====
local function toggleNoclip(state)
    noclipEnabled = state
    if noclipConnection then noclipConnection:Disconnect() end
    
    if state then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        notify("Noclip", "✅ Noclip Enabled")
    else
        -- Re-enable collisions
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        notify("Noclip", "❌ Noclip Disabled")
    end
end

-- ===== WALKSPEED FUNCTION =====
local function toggleSpeed(state)
    speedEnabled = state
    if state then
        humanoid.WalkSpeed = walkSpeed
        notify("Speed", "✅ Speed Enabled (Speed: " .. walkSpeed .. ")")
    else
        humanoid.WalkSpeed = 16
        notify("Speed", "❌ Speed Disabled")
    end
end

-- ===== INFINITE JUMP FUNCTION =====
local function toggleJump(state)
    jumpEnabled = state
    if jumpConnection then jumpConnection:Disconnect() end
    
    if state then
        humanoid.JumpPower = jumpPower
        jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if jumpEnabled then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("Jump", "✅ Infinite Jump Enabled")
    else
        humanoid.JumpPower = 50
        notify("Jump", "❌ Infinite Jump Disabled")
    end
end

-- ===== ESP FUNCTION =====
local function toggleESP(state)
    espEnabled = state
    
    if state then
        -- Add ESP to existing players
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = p.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.3
                table.insert(espObjects, highlight)
            end
        end
        
        -- Add ESP to new players
        game.Players.PlayerAdded:Connect(function(newPlayer)
            if espEnabled then
                newPlayer.CharacterAdded:Connect(function(newChar)
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = newChar
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.3
                    table.insert(espObjects, highlight)
                end)
            end
        end)
        notify("ESP", "✅ ESP Enabled")
    else
        -- Remove all ESP highlights
        for _, obj in pairs(espObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects = {}
        notify("ESP", "❌ ESP Disabled")
    end
end

-- ===== FLY CONTROLS (WASD + Space + Shift) =====
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if flyEnabled then
        if key == Enum.KeyCode.W then moveDirection = moveDirection + Vector3.new(0,0,-1) end
        if key == Enum.KeyCode.S then moveDirection = moveDirection + Vector3.new(0,0,1) end
        if key == Enum.KeyCode.A then moveDirection = moveDirection + Vector3.new(-1,0,0) end
        if key == Enum.KeyCode.D then moveDirection = moveDirection + Vector3.new(1,0,0) end
        if key == Enum.KeyCode.Space then moveDirection = moveDirection + Vector3.new(0,1,0) end
        if key == Enum.KeyCode.LeftShift then moveDirection = moveDirection + Vector3.new(0,-1,0) end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if flyEnabled then
        if key == Enum.KeyCode.W then moveDirection = moveDirection - Vector3.new(0,0,-1) end
        if key == Enum.KeyCode.S then moveDirection = moveDirection - Vector3.new(0,0,1) end
        if key == Enum.KeyCode.A then moveDirection = moveDirection - Vector3.new(-1,0,0) end
        if key == Enum.KeyCode.D then moveDirection = moveDirection - Vector3.new(1,0,0) end
        if key == Enum.KeyCode.Space then moveDirection = moveDirection - Vector3.new(0,1,0) end
        if key == Enum.KeyCode.LeftShift then moveDirection = moveDirection - Vector3.new(0,-1,0) end
    end
end)

-- ===== FLY MOVEMENT LOOP =====
game:GetService("RunService").RenderStepped:Connect(function()
    if flyEnabled and rootPart and bodyVelocity and bodyGyro then
        local cam = workspace.CurrentCamera
        local f = cam.CFrame.LookVector
        local r = cam.CFrame.RightVector
        local u = cam.CFrame.UpVector
        bodyVelocity.Velocity = (f * moveDirection.Z * -1 + r * moveDirection.X + u * moveDirection.Y) * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end
end)

-- ===== CHARACTER RESPAWN HANDLER =====
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Disable fly on respawn
    if flyEnabled then
        toggleFly(false)
    end
    if noclipEnabled then
        toggleNoclip(false)
    end
end)

-- ===== GUI CREATION =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkTeamGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- ===== TOGGLE BUTTON (POJOK LAYAR) =====
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
toggleBtn.Text = "☰"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- ===== MAIN MENU FRAME =====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- ===== TITLE BAR (DRAG) =====
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
title.BackgroundTransparency = 0.3
title.Text = "SkTeamProject V4"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BorderSizePixel = 0
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- ===== DRAG LOGIC =====
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== CREATE BUTTON FUNCTION =====
local function createButton(name, yPos, toggleFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 8)
    corner2.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        toggleFunc(state)
        btn.Text = name .. (state and " ✅" or " ❌")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(40, 40, 60)
    end)
    return btn
end

-- ===== CREATE ALL FEATURE BUTTONS =====
createButton("Fly", 45, toggleFly)
createButton("Noclip", 90, toggleNoclip)
createButton("Speed", 135, toggleSpeed)
createButton("Jump", 180, toggleJump)
createButton("ESP", 225, toggleESP)

-- ===== SETTINGS LABEL =====
local settingsLabel = Instance.new("TextLabel")
settingsLabel.Size = UDim2.new(0.85, 0, 0, 20)
settingsLabel.Position = UDim2.new(0.075, 0, 0, 275)
settingsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
settingsLabel.Text = "⚙️ Settings"
settingsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
settingsLabel.Font = Enum.Font.GothamBold
settingsLabel.TextSize = 12
settingsLabel.BorderSizePixel = 0
settingsLabel.Parent = mainFrame

-- ===== SPEED CONTROL =====
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 25)
speedLabel.Position = UDim2.new(0.075, 0, 0, 300)
speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedLabel.Text = "Walk: " .. walkSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.BorderSizePixel = 0
speedLabel.Parent = mainFrame

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.2, 0, 0, 25)
speedUpBtn.Position = UDim2.new(0.525, 0, 0, 300)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUpBtn.Text = "+"
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 14
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = mainFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.2, 0, 0, 25)
speedDownBtn.Position = UDim2.new(0.738, 0, 0, 300)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDownBtn.Text = "-"
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 14
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = mainFrame

speedUpBtn.MouseButton1Click:Connect(function()
    walkSpeed = walkSpeed + 5
    speedLabel.Text = "Walk: " .. walkSpeed
    if speedEnabled then
        humanoid.WalkSpeed = walkSpeed
    end
end)

speedDownBtn.MouseButton1Click:Connect(function()
    walkSpeed = math.max(16, walkSpeed - 5)
    speedLabel.Text = "Walk: " .. walkSpeed
    if speedEnabled then
        humanoid.WalkSpeed = walkSpeed
    end
end)

-- ===== FLY SPEED CONTROL =====
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedLabel.Position = UDim2.new(0.075, 0, 0, 330)
flySpeedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
flySpeedLabel.Text = "Fly: " .. flySpeed
flySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.TextSize = 12
flySpeedLabel.BorderSizePixel = 0
flySpeedLabel.Parent = mainFrame

local flySpeedUpBtn = Instance.new("TextButton")
flySpeedUpBtn.Size = UDim2.new(0.2, 0, 0, 25)
flySpeedUpBtn.Position = UDim2.new(0.525, 0, 0, 330)
flySpeedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
flySpeedUpBtn.Text = "+"
flySpeedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedUpBtn.Font = Enum.Font.GothamBold
flySpeedUpBtn.TextSize = 14
flySpeedUpBtn.BorderSizePixel = 0
flySpeedUpBtn.Parent = mainFrame

local flySpeedDownBtn = Instance.new("TextButton")
flySpeedDownBtn.Size = UDim2.new(0.2, 0, 0, 25)
flySpeedDownBtn.Position = UDim2.new(0.738, 0, 0, 330)
flySpeedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
flySpeedDownBtn.Text = "-"
flySpeedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedDownBtn.Font = Enum.Font.GothamBold
flySpeedDownBtn.TextSize = 14
flySpeedDownBtn.BorderSizePixel = 0
flySpeedDownBtn.Parent = mainFrame

flySpeedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
    flySpeedLabel.Text = "Fly: " .. flySpeed
end)

flySpeedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(10, flySpeed - 10)
    flySpeedLabel.Text = "Fly: " .. flySpeed
end)

-- ===== CLOSE BUTTON =====
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ===== TOGGLE MENU BUTTON HANDLER =====
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
    toggleBtn.Text = menuVisible and "☰" or "✕"
end)

-- ===== NOTIFICATION =====
notify("SkTeamProject V4", "✅ GUI Loaded! Press ☰ to open/close")
print("═══════════════════════════════════════")
print("SkTeamProject GUI V4 - FIXED VERSION")
print("═══════════════════════════════════════")
print("✅ All features working correctly")
print("🎮 Controls: WASD + Space + Shift")
print("═══════════════════════════════════════")
