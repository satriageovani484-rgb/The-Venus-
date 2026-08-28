-- Skrip GUI Box by The venus
-- Owner: The-Venus
-- Fitur: Fly, Noclip, WalkSpeed, Infinite Jump, ESP All Players
-- Menu bisa dibuka/tutup pake tombol di pojok layar

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Variabel
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

-- Fungsi Fly
local function toggleFly(state)
    if state then
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Parent = rootPart
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.Parent = rootPart
        flyEnabled = true
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        flyEnabled = false
    end
end

-- Fungsi Noclip
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

-- Fungsi WalkSpeed
local function toggleSpeed(state)
    speedEnabled = state
    humanoid.WalkSpeed = state and walkSpeed or 16
end

-- Fungsi Infinite Jump
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

-- Fungsi ESP
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

-- Kontrol Fly
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

game:GetService("RunService").RenderStepped:Connect(function()
    if flyEnabled and rootPart and bodyVelocity then
        local cam = workspace.CurrentCamera
        local f = cam.CFrame.LookVector
        local r = cam.CFrame.RightVector
        local u = cam.CFrame.UpVector
        bodyVelocity.Velocity = (f * moveDirection.Z * -1 + r * moveDirection.X + u * moveDirection.Y) * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end
end)

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkTeamGUI"
screenGui.Parent = player.PlayerGui

-- Tombol toggle menu (di pojok layar)
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

-- Drag Logic
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

createButton("Fly", 40, toggleFly)
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

-- Fungsi toggle menu (buka/tutup)
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
    toggleBtn.Text = menuVisible and "☰" or "✕"
end)

print("SkTeamProject GUI Loaded! Gas terus cuy! (Klik ☰ di pojok buka/tutup menu)")
