-- Auto Farm (TP theo tên mob + Bay lơ lửng) - GUI + Exit Button

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
frame.Size = UDim2.new(0, 220, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.Text = "⚔️ Auto Farm"
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

-- TextBox nhập tên mob
local mobBox = Instance.new("TextBox")
mobBox.Size = UDim2.new(1, -20, 0, 30)
mobBox.Position = UDim2.new(0, 10, 0, 40)
mobBox.PlaceholderText = "Nhập tên mob (VD: Trippi Troppi)"
mobBox.BackgroundColor3 = Color3.fromRGB(80,80,80)
mobBox.TextColor3 = Color3.new(1,1,1)
mobBox.Text = ""
mobBox.Font = Enum.Font.SourceSans
mobBox.TextSize = 16
mobBox.Parent = frame

local tpBtn = makeButton("Auto TP: OFF", 80)
local exitBtn = makeButton("❌ Exit Script", 120)

-- Auto TP
local autoTP = false
tpBtn.MouseButton1Click:Connect(function()
    autoTP = not autoTP
    tpBtn.Text = autoTP and "Auto TP: ON" or "Auto TP: OFF"
end)

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

-- Khoảng cách lơ lửng
local floatHeight = 20  -- chỉnh số này để cao hơn/thấp hơn

local running = true
task.spawn(function()
    while running do
        if autoTP and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local targetName = mobBox.Text
            if targetName ~= "" then
                local mob = getMobByName(targetName)
                if mob then
                    -- TP lên trên mob 1 khoảng
                    lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, floatHeight, 0)
                end
            end
        end
        task.wait(2)
    end
end)

-- Exit Script
exitBtn.MouseButton1Click:Connect(function()
    running = false
    autoTP = false
    screenGui:Destroy()
    print("❌ Auto Farm script stopped.")
end)
