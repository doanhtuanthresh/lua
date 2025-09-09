-- loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/refs/heads/main/test.lua"))()

-- Auto Farm (Dropdown Dungeon + Event Mob) - GUI + Exit Button

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Clear GUI nếu có sẵn
if CoreGui:FindFirstChild("FarmGUI") then
    CoreGui.FarmGUI:Destroy()
end

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 400)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.Text = "⚔️ Auto Farm (Dropdown)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local function makeButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = frame
    return btn
end

-- Tạo nút
local tpBtn = makeButton("Auto TP: OFF", 40)
local eventBtn = makeButton("Auto Event: OFF", 80)
local exitBtn = makeButton("❌ Exit Script", 340)

-- Danh sách mob
local dungeonMobList = { "Slime", "Goblin", "Skeleton", "BossGoblin" }
local eventMobList = { "GoldenSlime", "VoidReaper", "SantaGoblin" }

-- Mob được chọn
local selectedDungeonMob = dungeonMobList[1]
local selectedEventMob = eventMobList[1]

-- Dropdown Dungeon
local dungeonLabel = Instance.new("TextLabel")
dungeonLabel.Size = UDim2.new(1, -20, 0, 25)
dungeonLabel.Position = UDim2.new(0, 10, 0, 130)
dungeonLabel.Text = "🎯 Chọn Dungeon Mob:"
dungeonLabel.TextColor3 = Color3.new(1, 1, 1)
dungeonLabel.BackgroundTransparency = 1
dungeonLabel.Font = Enum.Font.SourceSansBold
dungeonLabel.TextSize = 16
dungeonLabel.Parent = frame

local dungeonDropdown = Instance.new("TextButton")
dungeonDropdown.Size = UDim2.new(1, -20, 0, 30)
dungeonDropdown.Position = UDim2.new(0, 10, 0, 160)
dungeonDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dungeonDropdown.TextColor3 = Color3.new(1, 1, 1)
dungeonDropdown.Text = selectedDungeonMob
dungeonDropdown.Font = Enum.Font.SourceSans
dungeonDropdown.TextSize = 16
dungeonDropdown.Parent = frame

local dungeonList = Instance.new("Frame")
dungeonList.Size = UDim2.new(1, -20, 0, #dungeonMobList * 30)
dungeonList.Position = UDim2.new(0, 10, 0, 190)
dungeonList.Visible = false
dungeonList.BackgroundColor3 = Color3.fromRGB(30,30,30)
dungeonList.Parent = frame

for _, mobName in ipairs(dungeonMobList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = mobName
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = dungeonList

    btn.MouseButton1Click:Connect(function()
        selectedDungeonMob = mobName
        dungeonDropdown.Text = mobName
        dungeonList.Visible = false
    end)
end

dungeonDropdown.MouseButton1Click:Connect(function()
    dungeonList.Visible = not dungeonList.Visible
end)

-- Dropdown Event
local eventLabel = Instance.new("TextLabel")
eventLabel.Size = UDim2.new(1, -20, 0, 25)
eventLabel.Position = UDim2.new(0, 10, 0, 200 + #dungeonMobList * 30)
eventLabel.Text = "🎯 Chọn Event Mob:"
eventLabel.TextColor3 = Color3.new(1, 1, 1)
eventLabel.BackgroundTransparency = 1
eventLabel.Font = Enum.Font.SourceSansBold
eventLabel.TextSize = 16
eventLabel.Parent = frame

local eventDropdown = Instance.new("TextButton")
eventDropdown.Size = UDim2.new(1, -20, 0, 30)
eventDropdown.Position = UDim2.new(0, 10, 0, 230 + #dungeonMobList * 30)
eventDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
eventDropdown.TextColor3 = Color3.new(1, 1, 1)
eventDropdown.Text = selectedEventMob
eventDropdown.Font = Enum.Font.SourceSans
eventDropdown.TextSize = 16
eventDropdown.Parent = frame

local eventList = Instance.new("Frame")
eventList.Size = UDim2.new(1, -20, 0, #eventMobList * 30)
eventList.Position = UDim2.new(0, 10, 0, 260 + #dungeonMobList * 30)
eventList.Visible = false
eventList.BackgroundColor3 = Color3.fromRGB(30,30,30)
eventList.Parent = frame

for _, mobName in ipairs(eventMobList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = mobName
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = eventList

    btn.MouseButton1Click:Connect(function()
        selectedEventMob = mobName
        eventDropdown.Text = mobName
        eventList.Visible = false
    end)
end

eventDropdown.MouseButton1Click:Connect(function()
    eventList.Visible = not eventList.Visible
end)

-- Logic điều khiển
local autoTP = false
local autoEvent = false
local running = true
local floatHeight = 20

tpBtn.MouseButton1Click:Connect(function()
    autoTP = not autoTP
    tpBtn.Text = autoTP and "Auto TP: ON" or "Auto TP: OFF"
end)

eventBtn.MouseButton1Click:Connect(function()
    autoEvent = not autoEvent
    eventBtn.Text = autoEvent and "Auto Event: ON" or "Auto Event: OFF"
end)

exitBtn.MouseButton1Click:Connect(function()
    running = false
    screenGui:Destroy()
end)

-- Hàm tìm mob theo tên
local function getMobByName(name)
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if string.find(mob.Name:lower(), name:lower()) and mob.Humanoid.Health > 0 then
                return mob
            end
        end
    end
    return nil
end

-- Farm Dungeon Mob
task.spawn(function()
    while running do
        if autoTP and selectedDungeonMob ~= "" and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local mob = getMobByName(selectedDungeonMob)
            while mob and mob.Humanoid.Health > 0 and autoTP do
                lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, floatHeight, 0)
                task.wait(0.5)
                mob = getMobByName(selectedDungeonMob)
            end
        end
        task.wait(1)
    end
end)

-- Farm Event Mob
task.spawn(function()
    while running do
        if autoEvent and selectedEventMob ~= "" and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local mob = getMobByName(selectedEventMob)
            while mob and mob.Humanoid.Health > 0 and autoEvent do
                lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, floatHeight, 0)
                task.wait(0.5)
                mob = getMobByName(selectedEventMob)
            end
        end
        task.wait(1)
    end
end)
