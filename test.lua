-- Auto Farm (TP theo list mob + Event Mob) - GUI + Exit Button

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUI setup
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("FarmGUI") then
    CoreGui.FarmGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 220)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.Text = "⚔️ Auto Farm (Dungeon + Event)"
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

local tpBtn = makeButton("Auto TP: OFF", 40)
local eventBtn = makeButton("Auto Event: OFF", 80)
local exitBtn = makeButton("❌ Exit Script", 120)

-- Mob list cần dọn (dungeon)
local mobList = {
    "Ti Ti",
    "Goblin",
    "Skeleton",
    "BossGoblin"
}

-- Khoảng cách lơ lửng
local floatHeight = 20

local autoTP = false
local autoEvent = false
local running = true

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
    autoTP = false
    autoEvent = false
    screenGui:Destroy()
    print("❌ Auto Farm script stopped.")
end)

-- Tìm mob theo tên (dành cho dungeon)
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

-- Tìm mob sự kiện (tên có "event")
local function findEventMob()
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if string.find(mob.Name:lower(), "event") and mob.Humanoid.Health > 0 then
                return mob
            end
        end
    end
    return nil
end

-- Auto TP dungeon mob
task.spawn(function()
    while running do
        if autoTP and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            for _, mobName in ipairs(mobList) do
                local mob = getMobByName(mobName)
                while mob and mob.Humanoid.Health > 0 and autoTP do
                    lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, floatHeight, 0)
                    task.wait(0.5)
                    mob = getMobByName(mobName)
                end
            end
        end
        task.wait(1)
    end
end)

-- Auto TP event mob
task.spawn(function()
    while running do
        if autoEvent and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local mob = findEventMob()
            if mob then
                lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, floatHeight, 0)
                repeat
                    task.wait(0.5)
                    mob = findEventMob()
                until not mob or mob.Humanoid.Health <= 0 or not autoEvent
            end
        end
        task.wait(1)
    end
end)
