local ToTo = {}
ToTo.auto = false
local farming = false

-- Lọc ra tất cả boss "To To Sahur" còn sống
local function getAllBosses()
    local bosses = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") 
        and string.find(string.lower(obj.Name), "to to sahur") 
        and obj:FindFirstChild("Humanoid") 
        and obj:FindFirstChild("HumanoidRootPart") 
        and obj.Humanoid.Health > 0 then
            table.insert(bosses, obj)
        end
    end
    return bosses
end

-- Request attack
local function attack(mob)
    local remote = game.ReplicatedStorage:FindFirstChild("RequestAttack")
    if remote and mob then
        remote:FireServer(mob)
    end
end

-- Teleport và farm boss cho đến khi chết
local function farmBoss(mob)
    local player = game.Players.LocalPlayer
    local char = player.Character
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

            local bosses = getAllBosses()
            if #bosses == 0 then
                -- không có boss → chờ spawn lại
                task.wait(5)
            else
                -- farm từng boss một
                for _, boss in ipairs(bosses) do
                    if not ToTo.auto then break end
                    farmBoss(boss)
                    task.wait(0.5)
                end
            end
        end
        farming = false
    end)
end

return ToTo
