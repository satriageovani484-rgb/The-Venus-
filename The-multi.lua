-- Skrip Gabungan by SkTeamProject
-- Owner: The-Venus
-- Fitur: Fly (Future of Fly V3), Noclip, WalkSpeed, Infinite Jump, ESP
-- GUI: Dragable + Tombol ☰ buka/tutup menu

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- ===== VARIABEL FITUR =====
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local jumpEnabled = false
local espEnabled = false
local flySpeed = 60
local walkSpeed = 32
local jumpPower = 70
local espObjects = {}
local noclipConnection = nil
local jumpConnection = nil
local menuVisible = true

-- ===== FLY SYSTEM (DARI KODE LO) =====
local nowe = false
local speeds = 1
local tpwalking = false
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 50
local speed = 0
local bg, bv

local function startFly()
    if not char or not char.Parent then return end
    
    local plr = player
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    
    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0,0.1,0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    humanoid.PlatformStand = true
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if not nowe then return end
        if not torso or not torso.Parent then return end
        
        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + 0.5 + (speed/maxspeed)
            if speed > maxspeed then speed = maxspeed end
        elseif speed ~= 0 then
            speed = speed - 1
            if speed < 0 then speed = 0 end
        end
        
        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
            bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (ctrl.f+ctrl.b)) + 
                          ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l+ctrl.r, (ctrl.f+ctrl.b)*0.2, 0).p) - 
                          workspace.CurrentCamera.CFrame.p)) * speed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        elseif speed ~= 0 then
            bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lastctrl.f+lastctrl.b)) + 
                          ((workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l+lastctrl.r, (lastctrl.f+lastctrl.b)*0.2, 0).p) - 
                          workspace.CurrentCamera.CFrame.p)) * speed
        else
            bv.velocity = Vector3.new(0,0,0)
        end
        
        bg.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed), 0, 0)
    end)
end

local function stopFly()
    nowe = false
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    humanoid.PlatformStand = false
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    speed = 0
    tpwalking = false
end

local function toggleFlyFromButton(state)
    if state then
        nowe = true
        startFly()
    else
        stopFly()
    end
    flyEnabled = state
end

-- ===== WALKSPEED =====
local function toggleSpeed(state)
    speedEnabled = state
    humanoid.WalkSpeed = state and walkSpeed or 16
end

-- ===== INFINITE JUMP =====
local function toggleJump(state)
    jumpEnabled = state
    if jumpConnection then jumpConnection:Disconnect() end
    if state then
        humanoid.JumpPower = jumpPower
        jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    else
        humanoid.JumpPower = 50
    end
end

-- ===== NOCLIP =====
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
    end
end

-- ===== ESP =====
local function toggleESP(state)
    espEnabled = state
    if state then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = p.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                table.insert(espObjects, highlight)
            end
        end
        game.Players.PlayerAdded:Connect(function(newPlayer)
            if espEnabled then
                newPlayer.CharacterAdded:Connect(function(char)
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    table.insert(espObjects, highlight)
                end)
            end
        end)
    else
        for _, obj in pairs(espObjects) do
            obj:Destroy()
        end
        espObjects = {}
    end
end

-- ===== KEYBOARD CONTROL UNTUK FLY =====
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if nowe then
        if key == Enum.KeyCode.W then ctrl.f = 1 end
        if key == Enum.KeyCode.S then ctrl.b = -1 end
        if key == Enum.KeyCode.A then ctrl.l = -1 end
        if key == Enum.KeyCode.D then ctrl.r = 1 end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if nowe then
        if key == Enum.KeyCode.W then ctrl.f = 0 end
        if key == Enum.KeyCode.S then ctrl.b = 0 end
        if key == Enum.KeyCode.A then ctrl.l = 0 end
        if key == Enum.KeyCode.D then ctrl.r = 0 end
    end
end)

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkTeamGUI"
screenGui.Parent = player.PlayerGui

-- Tombol toggle menu (di pojok layar, bisa digeser)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
toggleBtn.Text = "☰"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.Parent = screenGui
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- Drag Logic for Toggle Button
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Main Menu (bisa digeser)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title (Drag Handler)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 0.2
title.Text = "SkTeamProject"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Drag Logic for Main Frame
local dragMain = false
local dragMainInput = nil
local dragMainStart = nil
local startMainPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragMain = true
        dragMainStart = input.Position
        startMainPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragMain = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragMainInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragMainInput and dragMain then
        local delta = input.Position - dragMainStart
        mainFrame.Position = UDim2.new(startMainPos.X.Scale, startMainPos.X.Offset + delta.X, startMainPos.Y.Scale, startMainPos.Y.Offset + delta.Y)
    end
end)

-- Fungsi buat bikin tombol toggle di dalam menu
local function createButton(name, yPos, toggleFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = mainFrame
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 6)
    corner2.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        toggleFunc(state)
        btn.Text = name .. (state and " ✅" or " ❌")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    end)
    return btn
end

createButton("Fly", 40, toggleFlyFromButton)
createButton("Noclip", 80, toggleNoclip)
createButton("Speed", 120, toggleSpeed)
createButton("Jump", 160, toggleJump)
createButton("ESP", 200, toggleESP)

-- Tombol Close di dalam menu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Toggle menu buka/tutup
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
    toggleBtn.Text = menuVisible and "☰" or "✕"
end)

print("SkTeamProject GUI Loaded! Fly pake WASD, menu bisa digeser!")
