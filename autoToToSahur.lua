local ToTo = {}
ToTo.auto = false

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Patch lỗi event
if not TeleportService:FindFirstChild("LocalPlayerArrived") then
    local fake = Instance.new("BindableEvent")
    fake.Name = "LocalPlayerArrived"
    fake.Parent = TeleportService
    warn("[Patch] Added fake TeleportService.LocalPlayerArrived")
end

-- Remote
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack

-- Boss spawn points
local bossSpawns = {
    ["Larila Desert"]    = CFrame.new(513, 105, -77),
    ["Tralalero Ocean"]  = CFrame.new(-287, 109, -1866),
    ["Mount Ambalabu"]   = CFrame.new(-1531, 147, 1375),
    ["Chicleteiramania"] = CFrame.new(-2640, 113.7, -899),
    ["Nuclearo Core"]    = CFrame.new(-2200, 291, -3756),
    ["Udin Dinlympus"]   = CFrame.new(1294, -41, -4262),
    ["Glorbo Heights"]   = CFrame.new(-3945, 51, 934),
    ["Brainrot Abyss"]   = CFrame.new(-1788, 199, 5011),
    ["Bombardino Sewer"] = CFrame.new(-3607, 197, 2246),
}

-- Detect boss
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

-- Teleport thẳng đến map boss spawn
local function gotoBoss(boss)
    if boss and boss:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for name, cf in pairs(bossSpawns) do
            if (boss.HumanoidRootPart.Position - cf.Position).Magnitude < 150 then
                hrp.CFrame = cf + Vector3.new(0, 5, 0)
                print("[ToTo] Tele thẳng đến boss ở:", name)
                break
            end
        end
    end
end

-- Attack boss (cooldown chống spam)
local lastAttack = 0
local function attack(mob)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        if tick() - lastAttack >= 0.3 then
            lastAttack = tick()
            pcall(function()
                RequestAttack:InvokeServer(mob.HumanoidRootPart.CFrame)
            end)
        end
    end
end

-- Farm boss
local function farmBoss(mob)
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart

    gotoBoss(mob) -- nhảy thẳng đến map boss spawn

    while ToTo.auto
    and mob
    and mob:FindFirstChild("Humanoid")
    and mob.Humanoid.Health > 0 do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            break -- chờ respawn
        end
        pcall(function()
            if mob:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                attack(mob)
            end
        end)
        task.wait(0.4)
    end
end

-- Main loop
function ToTo.start()
    task.spawn(function()
        while ToTo.auto do
            if game.PlaceId ~= 111989938562194 then
                task.wait(3)
                continue
            end

            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(2)
                continue
            end

            local boss = getBoss()
            if boss then
                farmBoss(boss)
            else
                -- Không patrol nữa, chỉ quét boss trong workspace
                print("[ToTo] Boss chưa spawn, chờ...")
                task.wait(3)
            end
        end
    end)
end

return ToTo
