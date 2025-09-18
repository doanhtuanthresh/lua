local ToTo = {}
ToTo.auto = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack

-- 📍 Vị trí spawn To To Sahur theo từng map
local bossSpawns = {
    ["To To To To To To To Sahur"]                     = CFrame.new(513, 105, -77),       -- Larila Desert
    ["To To To To To To To To Sahur"]                  = CFrame.new(-287, 109, -1866),    -- Tralalero Ocean
    ["To To To To To To To To To Sahur"]               = CFrame.new(-1531, 147, 1375),    -- Mount Ambalabu
    ["To To To To To To To To To To Sahur"]             = CFrame.new(-2640, 113.7, -899),  -- Chicleteiramania
    ["To To To To To To To To To To To Sahur"]           = CFrame.new(-2200, 291, -3756),   -- Nuclearo Core
    ["To To To To To To To To To To To To Sahur"]         = CFrame.new(1294, -41, -4262),    -- Udin Dinlympus
    ["To To To To To To To To To To To To To Sahur"]       = CFrame.new(-3945, 51, 934),      -- Glorbo Heights
    ["To To To To To To To To To To To To To To Sahur"]     = CFrame.new(-1788, 199, 5011),    -- Brainrot Abyss
    ["To To To To To To To To To To To To To To To Sahur"]   = CFrame.new(-3607, 197, 2246),    -- Bombardino Sewer
    ["To To To To To To To To To To To To To To To To Sahur"] = CFrame.new(-6919, 75, -2238),   -- Goaaat Galaxy
}

-- 🧍 Lấy HumanoidRootPart của người chơi
local function getHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- 📡 Tìm boss hiện có trong workspace
local function getBoss()
    for _, obj in ipairs(workspace:GetChildren()) do
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

-- 📍 Teleport tới boss (dựa vào HRP của boss)
local function teleportToBoss(boss)
    local hrp = getHRP()
    if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15)
    end
end

-- 📍 Teleport đi tuần tra các map để tìm boss
local function patrolMaps()
    local hrp = getHRP()
    if not hrp then return end
    for name, cf in pairs(bossSpawns) do
        if not ToTo.auto then break end
        hrp.CFrame = cf + Vector3.new(0,5,0)
        print("🧭 Đang tuần tra map:", name)
        task.wait(2.5)
        if getBoss() then break end
    end
end

-- ⚔️ Gửi yêu cầu đánh boss
local function attackBoss(mob)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            RequestAttack:InvokeServer(mob.HumanoidRootPart.CFrame)
        end)
    end
end

-- 💥 Farm boss khi phát hiện
local function farmBoss(mob)
    local hrp = getHRP()
    if not hrp then return end

    teleportToBoss(mob)
    task.wait(1)

    while ToTo.auto 
    and mob 
    and mob:FindFirstChild("Humanoid")
    and mob.Humanoid.Health > 0 do

        if not getHRP() then break end

        pcall(function()
            if mob:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                attackBoss(mob)
            end
        end)
        task.wait(0.4)
    end
end

-- ♻️ Auto loop
function ToTo.start()
    task.spawn(function()
        while ToTo.auto do
            if game.PlaceId ~= 111989938562194 then
                task.wait(2)
                continue
            end

            if not getHRP() then
                task.wait(2)
                continue
            end

            local boss = getBoss()
            if boss then
                print("🎯 Tìm thấy To To Sahur:", boss.Name)
                farmBoss(boss)
            else
                patrolMaps()
            end
        end
    end)
end

return ToTo
