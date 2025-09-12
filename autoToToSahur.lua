local ToTo = {}
ToTo.auto = false
local running = false

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tìm toàn bộ boss "To To Sahur"
local function getAllBosses()
    local bosses = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid") 
        and obj:FindFirstChild("HumanoidRootPart") then
            if string.find(string.lower(obj.Name), "to to sahur") 
            and obj.Humanoid.Health > 0 then
                table.insert(bosses, obj)
            end
        end
    end
    return bosses
end

-- Tìm boss gần nhất trong toàn world
local function getNearestBoss()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local nearest, dist = nil, math.huge
    for _, boss in ipairs(getAllBosses()) do
        local d = (boss.HumanoidRootPart.Position - hrp.Position).Magnitude
        if d < dist then
            nearest = boss
            dist = d
        end
    end
    return nearest
end

-- Teleport + Attack
local function farmBoss(boss)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    while ToTo.auto and boss 
    and boss:FindFirstChild("Humanoid") 
    and boss.Humanoid.Health > 0 do
        pcall(function()
            -- dịch chuyển sát boss
            hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

            -- tấn công
            local remote = game.ReplicatedStorage:FindFirstChild("RequestAttack")
            if remote then
                remote:FireServer(boss)
            elseif boss:FindFirstChild("ClickDetector") then
                fireclickdetector(boss.ClickDetector)
            end
        end)
        task.wait(0.3)
    end
end

-- Main loop
function ToTo.start()
    if running then return end
    running = true

    task.spawn(function()
        while ToTo.auto do
            local boss = getNearestBoss()
            if boss then
                farmBoss(boss)
            else
                -- không còn boss nào sống → chờ spawn lại
                task.wait(5)
            end
            task.wait(0.5)
        end
        running = false
    end)
end

return ToTo
