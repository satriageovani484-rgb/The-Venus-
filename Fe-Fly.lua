-- Merged Fe-Fly.lua + The-multi.lua (improved fly implementation)
-- Kept original GUI from Fe-Fly.lua but replaced the faulty fly logic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "main"
main.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "click to fly!"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "FUTURE OF FLY GUI V3"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "60" -- default fly speed
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14.000
speed.TextWrapped = true

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true

closebutton.Name = "Close"
closebutton.Parent = main.Frame
closebutton.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
closebutton.Font = "SourceSans"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position =  UDim2.new(0, 0, -1, 27)

mini.Name = "minimize"
mini.Parent = main.Frame
mini.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
mini.Font = "SourceSans"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)

mini2.Name = "minimize2"
mini2.Parent = main.Frame
mini2.BackgroundColor3 = Color3.fromRGB(144, 213, 255)
mini2.Font = "SourceSans"
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

-- VARIABLES FOR FLY
local player = Players.LocalPlayer
local speaker = player
local flyEnabled = false
local flySpeed = 60 -- default
local bodyVelocity = nil
local bodyGyro = nil
local moveDirection = Vector3.new(0,0,0)
local keys = {
    [Enum.KeyCode.W] = Vector3.new(0,0,-1),
    [Enum.KeyCode.S] = Vector3.new(0,0,1),
    [Enum.KeyCode.A] = Vector3.new(-1,0,0),
    [Enum.KeyCode.D] = Vector3.new(1,0,0),
    [Enum.KeyCode.Space] = Vector3.new(0,1,0),
    [Enum.KeyCode.LeftShift] = Vector3.new(0,-1,0),
}
local keysPressed = {}

-- SETUP
StarterGui:SetCore("SendNotification", { 
    Title = "FLY GUI V4";
    Text = "Merged by script";
    Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
})

Frame.Active = true
Frame.Draggable = true

-- HELPER: enable/disable fly (safe implementation)
local function enableFly(state)
    flyEnabled = state
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if state then
        -- clean existing
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = root

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root

        if humanoid then
            humanoid.PlatformStand = true
        end
        onof.Text = "STOP FLY"
        StarterGui:SetCore("SendNotification", {Title = "Fly"; Text = "✅ Fly Enabled"})
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        if humanoid then
            humanoid.PlatformStand = false
        end
        moveDirection = Vector3.new(0,0,0)
        onof.Text = "click to fly!"
        StarterGui:SetCore("SendNotification", {Title = "Fly"; Text = "❌ Fly Disabled"})
    end
end

-- UPDATE moveDirection
local function updateMoveDirection()
    moveDirection = Vector3.new(0,0,0)
    if flyEnabled then
        for k, dir in pairs(keys) do
            if keysPressed[k] then
                moveDirection = moveDirection + dir
            end
        end
    end
end

-- Input handlers
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if keys[k] then
            keysPressed[k] = true
            updateMoveDirection()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if keys[k] then
            keysPressed[k] = false
            updateMoveDirection()
        end
    end
end)

-- Render loop to move player when flying
RunService.RenderStepped:Connect(function()
    if not flyEnabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root or not bodyVelocity or not bodyGyro then return end

    local cam = workspace.CurrentCamera
    local f = cam.CFrame.LookVector
    local r = cam.CFrame.RightVector
    local u = cam.CFrame.UpVector

    local dir = (f * moveDirection.Z * -1) + (r * moveDirection.X) + (u * moveDirection.Y)
    if dir.Magnitude > 0 then
        dir = dir.Unit
    end
    bodyVelocity.Velocity = dir * flySpeed
    bodyGyro.CFrame = cam.CFrame
end)

-- Character respawn cleanup
Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    -- small delay for parts to exist
    wait(0.5)
    enableFly(false)
end)

-- GUI BUTTONS BEHAVIOR
onof.MouseButton1Down:connect(function()
    enableFly(not flyEnabled)
end)

-- UP/DOWN: move character vertically while clicking
local upConn
up.MouseButton1Down:connect(function()
    upConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not flyEnabled then
            hrp.CFrame = hrp.CFrame * CFrame.new(0,1,0)
        end
    end)
end)
up.MouseButton1Up:connect(function()
    if upConn then upConn:Disconnect() upConn = nil end
end)

local downConn
down.MouseButton1Down:connect(function()
    downConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not flyEnabled then
            hrp.CFrame = hrp.CFrame * CFrame.new(0,-1,0)
        end
    end)
end)
down.MouseButton1Up:connect(function()
    if downConn then downConn:Disconnect() downConn = nil end
end)

-- Speed control with plus/minus (affects flySpeed shown in label)
plus.MouseButton1Down:connect(function()
    flySpeed = flySpeed + 10
    speed.Text = tostring(flySpeed)
end)

mine.MouseButton1Down:connect(function()
    flySpeed = math.max(10, flySpeed - 10)
    speed.Text = tostring(flySpeed)
end)

-- Close and minimize
closebutton.MouseButton1Click:Connect(function()
    main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
    up.Visible = false
    down.Visible = false
    onof.Visible = false
    plus.Visible = false
    speed.Visible = false
    mine.Visible = false
    mini.Visible = false
    mini2.Visible = true
    main.Frame.BackgroundTransparency = 1
    closebutton.Position =  UDim2.new(0, 0, -1, 57)
end)

mini2.MouseButton1Click:Connect(function()
    up.Visible = true
    down.Visible = true
    onof.Visible = true
    plus.Visible = true
    speed.Visible = true
    mine.Visible = true
    mini.Visible = true
    mini2.Visible = false
    main.Frame.BackgroundTransparency = 0 
    closebutton.Position =  UDim2.new(0, 0, -1, 27)
end)

-- initial label
speed.Text = tostring(flySpeed)

print("Merged Fe-Fly.lua -> using improved fly logic")
