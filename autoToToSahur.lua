local ToTo = {}
ToTo.auto = false
local farming = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack

-- Tìm boss "To To Sahur" còn sống (trả về boss đầu tiên)
local function getBoss()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") 
        and string.find(string.lower(obj.Name), "to to sahur") 
        and obj:FindFirstChild("Humanoid") 
        and obj:FindFirstChild("HumanoidRootPart") 
        and obj.Humanoid.Health > 0 then
            return obj
        end
    end
    return nil
end

-- Request attack (gửi CFrame tới server)
local function attack(mob)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            RequestAttack:InvokeServer(mob.HumanoidRootPart.CFrame)
        end)
    end
end

-- Teleport và farm boss cho đến khi chết
local function farmBoss(mob)
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart

    while ToTo.auto 
    and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        pcall(function()
            if mob:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                attack(mob)
            end
        end)
        task.wait(0.3)
    end
end

-- Bắt đầu vòng lặp Auto To To Sahur
function ToTo.start()
    if farming then return end
    farming = true

    task.spawn(function()
        while ToTo.auto do
            if game.PlaceId ~= 111989938562194 then
                task.wait(2)
                continue
            end

            local boss = getBoss()
            if boss then
                farmBoss(boss)
            else
                -- không có boss → chờ spawn lại
                task.wait(3)
            end
        end
        farming = false
    end)
end

return ToTo
