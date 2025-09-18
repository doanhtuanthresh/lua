local ToTo = {}
ToTo.auto = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack

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

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 📡 Quét tất cả boss sống đang tồn tại
local function getAliveBosses()
    local bosses = {}
    for _, obj in ipairs(workspace:GetChildren()) do
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

local function attackBoss(mob)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            RequestAttack:InvokeServer(mob.HumanoidRootPart.CFrame)
        end)
    end
end

local function farmBoss(mob)
    local hrp = getHRP()
    if not hrp then return end
    teleportToBossMap(mob)
    task.wait(1)

    while ToTo.auto and mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 do
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

            local bosses = getAliveBosses()
            if #bosses > 0 then
                print("🎯 Phát hiện", #bosses, "boss To To Sahur sống.")
                for _, boss in ipairs(bosses) do
                    if not ToTo.auto then break end
                    farmBoss(boss)
                end
            else
                -- nếu muốn có patrol fallback thì thêm tại đây
                print("🧭 Không có boss nào sống → chờ hồi sinh...")
                task.wait(3)
            end
        end
    end)
end

return ToTo
