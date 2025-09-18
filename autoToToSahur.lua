local ToTo = {}
ToTo.auto = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack

-- 📍 Vị trí spawn To To Sahur theo từng map
local bossSpawns = {
    ["To To To To To To To Sahur"]                       = CFrame.new(513, 105, -77),        
    ["To To To To To To To To Sahur"]                    = CFrame.new(-287, 109, -1866),     
    ["To To To To To To To To To Sahur"]                 = CFrame.new(-1531, 147, 1375),     
    ["To To To To To To To To To To Sahur"]               = CFrame.new(-2640, 113.7, -899),   
    ["To To To To To To To To To To To Sahur"]             = CFrame.new(-2200, 291, -3756),    
    ["To To To To To To To To To To To To Sahur"]           = CFrame.new(1294, -41, -4262),     
    ["To To To To To To To To To To To To To Sahur"]         = CFrame.new(-3945, 51, 934),       
    ["To To To To To To To To To To To To To To Sahur"]       = CFrame.new(-1788, 199, 5011),     
    ["To To To To To To To To To To To To To To To Sahur"]     = CFrame.new(-3607, 197, 2246),     
    ["To To To To To To To To To To To To To To To To Sahur"]   = CFrame.new(-6919, 75, -2238),      
}

-- 📋 Danh sách boss spawn bị bỏ lỡ (pending)
local pendingBosses = {}

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

-- 📍 Teleport tới đúng map chứa boss (chỉ 1 lần)
local function teleportToBossMap(boss)
    if not boss or not boss:FindFirstChild("HumanoidRootPart") then return end
    local hrp = getHRP()
    if not hrp then return end

    for name, cf in pairs(bossSpawns) do
        if string.lower(name) == string.lower(boss.Name) then
            hrp.CFrame = cf + Vector3.new(0, 5, 0)
            print("📍 Teleport tới map chứa boss:", name)
            break
        end
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

    teleportToBossMap(mob) -- chỉ gọi 1 lần trước khi đánh
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

-- 🟢 Theo dõi boss mới spawn để thêm vào pendingBosses
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") 
    and string.find(string.lower(obj.Name), "to to sahur")
    and obj:FindFirstChildOfClass("Humanoid") then
        print("⚡ Phát hiện boss mới spawn:", obj.Name)
        table.insert(pendingBosses, obj.Name)
    end
end)

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

            -- Nếu có boss đang hiện diện → farm
            local boss = getBoss()
            if boss then
                print("🎯 Tìm thấy To To Sahur:", boss.Name)
                farmBoss(boss)

            -- Nếu không có boss hiện diện nhưng có boss pending spawn
            elseif #pendingBosses > 0 then
                local bossName = table.remove(pendingBosses, 1)
                print("📦 Có boss pending:", bossName, "→ teleport tới map ngay")
                local cf = bossSpawns[bossName]
                if cf and getHRP() then
                    getHRP().CFrame = cf + Vector3.new(0,5,0)
                end

            -- Nếu không có gì → patrol như cũ
            else
                patrolMaps()
            end
        end
    end)
end

return ToTo
