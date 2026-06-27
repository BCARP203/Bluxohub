

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- UI shit
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BluxoHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 280)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "ERLC Auto-Rob v3 – C# to LUA"
titleText.TextColor3 = Color3.fromRGB(255, 200, 50)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Center
titleText.Parent = titleBar

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

-- Glass rob toggle
local glassToggle = Instance.new("TextButton")
glassToggle.Size = UDim2.new(0.4, 0, 0, 40)
glassToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
glassToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
glassToggle.Text = "Rob Glass"
glassToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
glassToggle.Font = Enum.Font.GothamBold
glassToggle.TextSize = 14
glassToggle.BorderSizePixel = 0
glassToggle.Parent = mainFrame

-- Loot toggle
local lootToggle = Instance.new("TextButton")
lootToggle.Size = UDim2.new(0.4, 0, 0, 40)
lootToggle.Position = UDim2.new(0.55, 0, 0.2, 0)
lootToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lootToggle.Text = "Auto Loot"
lootToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
lootToggle.Font = Enum.Font.GothamBold
lootToggle.TextSize = 14
lootToggle.BorderSizePixel = 0
lootToggle.Parent = mainFrame

-- Door bypass toggle
local doorToggle = Instance.new("TextButton")
doorToggle.Size = UDim2.new(0.4, 0, 0, 40)
doorToggle.Position = UDim2.new(0.05, 0, 0.5, 0)
doorToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
doorToggle.Text = "Bypass Doors"
doorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
doorToggle.Font = Enum.Font.GothamBold
doorToggle.TextSize = 14
doorToggle.BorderSizePixel = 0
doorToggle.Parent = mainFrame

-- Anti-detection toggle
local antiToggle = Instance.new("TextButton")
antiToggle.Size = UDim2.new(0.4, 0, 0, 40)
antiToggle.Position = UDim2.new(0.55, 0, 0.5, 0)
antiToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
antiToggle.Text = "Anti-Detect"
antiToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
antiToggle.Font = Enum.Font.GothamBold
antiToggle.TextSize = 14
antiToggle.BorderSizePixel = 0
antiToggle.Parent = mainFrame

-- ========== CORE FUNCTIONS ==========

-- Glass detection from the C# GlassAreaRectangle
local function getGlassParts()
    local glassParts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Glass then
            table.insert(glassParts, obj)
        end
    end
    return glassParts
end

local function robGlass(part)
    if not part or not part.Parent then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- Teleport to glass (simulate interaction)
    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
    task.wait(0.15)
    -- Find remote event for robbing
    local remote = ReplicatedStorage:FindFirstChild("GlassRob") or ReplicatedStorage:FindFirstChild("BreakGlass")
    if remote then
        remote:FireServer(part)
    else
        -- Fallback: find any remote with "glass" in name
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("glass") then
                v:FireServer(part)
                break
            end
        end
    end
end

-- Auto loot items (money, guns, etc.)
local function lootItems()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and item:FindFirstChild("ClickDetector") then
            root.CFrame = CFrame.new(item.Position + Vector3.new(0, 1, 0))
            task.wait(0.1)
            local click = item:FindFirstChildOfClass("ClickDetector")
            if click then
                fireclickdetector(click)
                task.wait(0.3)
            end
        end
    end
end

-- Door bypass (find locked doors and force open)
local function bypassDoors()
    for _, door in pairs(Workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name:lower():find("door") then
            local hinge = door:FindFirstChild("HingeConstraint")
            if hinge then
                -- Attempt to unlock via remote
                local unlockRemote = ReplicatedStorage:FindFirstChild("UnlockDoor") or ReplicatedStorage:FindFirstChild("DoorInteract")
                if unlockRemote then
                    unlockRemote:FireServer(door)
                end
            end
        end
    end
end

-- Anti-detection: randomize delays, fake movement jitter
local function antiDetect()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local jitter = Vector3.new(math.random(-1,1), 0, math.random(-1,1)) * 0.2
    root.CFrame = root.CFrame + jitter
end

-- ========== LOOP CONTROLS ==========

local glassRunning = false
local lootRunning = false
local doorRunning = false
local antiRunning = false

local glassConn, lootConn, doorConn, antiConn

glassToggle.MouseButton1Click:Connect(function()
    glassRunning = not glassRunning
    if glassRunning then
        glassToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        glassToggle.Text = "Rob Glass ON"
        statusLabel.Text = "Status: Robbing glass"
        glassConn = RunService.Heartbeat:Connect(function()
            if not glassRunning then return end
            local glasses = getGlassParts()
            for _, g in pairs(glasses) do
                pcall(robGlass, g)
                task.wait(0.3 + math.random() * 0.2) -
            end
        end)
    else
        glassToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        glassToggle.Text = "Rob Glass"
        statusLabel.Text = "Status: Idle"
        if glassConn then glassConn:Disconnect() end
    end
end)

lootToggle.MouseButton1Click:Connect(function()
    lootRunning = not lootRunning
    if lootRunning then
        lootToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        lootToggle.Text = "Auto Loot ON"
        statusLabel.Text = "Status: Looting"
        lootConn = RunService.Heartbeat:Connect(function()
            if not lootRunning then return end
            pcall(lootItems)
            task.wait(0.5 + math.random() * 0.3)
        end)
    else
        lootToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        lootToggle.Text = "Auto Loot"
        statusLabel.Text = "Status: Idle"
        if lootConn then lootConn:Disconnect() end
    end
end)

doorToggle.MouseButton1Click:Connect(function()
    doorRunning = not doorRunning
    if doorRunning then
        doorToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        doorToggle.Text = "Bypass ON"
        statusLabel.Text = "Status: Bypassing doors"
        doorConn = RunService.Stepped:Connect(function()
            if not doorRunning then return end
            pcall(bypassDoors)
            task.wait(1)
        end)
    else
        doorToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        doorToggle.Text = "Bypass Doors"
        statusLabel.Text = "Status: Idle"
        if doorConn then doorConn:Disconnect() end
    end
end)

antiToggle.MouseButton1Click:Connect(function()
    antiRunning = not antiRunning
    if antiRunning then
        antiToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        antiToggle.Text = "Anti-Detect ON"
        antiConn = RunService.RenderStepped:Connect(function()
            if not antiRunning then return end
            pcall(antiDetect)
        end)
    else
        antiToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        antiToggle.Text = "Anti-Detect"
        if antiConn then antiConn:Disconnect() end
    end
end)


UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.End then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
