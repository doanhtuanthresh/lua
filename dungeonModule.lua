-- dungeonModule.lua
local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = true

local running = false

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- Remote attack (check cả 2 kiểu viết hoa/thường)
local AttackRemote = ReplicatedStorage:FindFirstChild("requestattack")
    or ReplicatedStorage:FindFirstChild("RequestAttack")

-- =========================
-- Danh sách mob cần target
-- =========================
Dungeon.TargetList = {
    "Tang Tang Tang Tang Kelentang",
    "Orc",
    "Skeleton",
    "Bearini", -- boss
    -- thêm mob khác tuỳ dungeon
}

-- Helper: kiểm tra tên mob có trong list
local function inTargetList(name)
    if not name then return false end
    for _, n in ipairs(Dungeon.TargetList) do
        if string.find(string.lower(name), string.lower(n), 1, true) then
            return true
        end
    end
    return false
end

-- Detect dungeon (dựa vào boss trong TargetList)
function Dungeon.detectDungeon()
    for _, mobName in ipairs(Dungeon.TargetList) do
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                if string.find(string.lower(v.Name), string.lower(mobName), 1, true) then
                    return "Dungeon (" .. mobName .. ")"
                end
            end
        end
    end
    return "Unknown"
end

-- =========================
-- Tìm mob gần nhất trong list
-- =========================
function Dungeon.getNearestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local nearest, dist = nil, math.huge
    for _, v in ipairs(Workspace:GetChildren()) do
        local humanoid = v:FindFirstChild("Humanoid")
        local root = v:FindFirstChild("HumanoidRootPart")
        if v:IsA("Model") and humanoid and root and humanoid.Health > 0 then
            if inTargetList(v.Name) then
                local d = (root.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- =========================
-- Dịch chuyển + Attack mob
-- =========================
local function attackMob(mob)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Dịch chuyển lên mob
    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

    -- AntiFall giữ player không rơi
    if not hrp:FindFirstChild("AntiFall") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "AntiFall"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = hrp
    end

    -- Tấn công mob
    if AttackRemote then
        AttackRemote:FireServer(mob)
    elseif mob:FindFirstChild("ClickDetector") then
        fireclickdetector(mob.ClickDetector)
    end
end

-- =========================
-- Kill 1 mob
-- =========================
function Dungeon.killMob(mob)
    while Dungeon.autoDungeon
    and mob
    and mob:FindFirstChild("Humanoid")
    and mob.Humanoid.Health > 0 do
        pcall(function() attackMob(mob) end)
        task.wait(0.2)
    end

    -- Clear AntiFall
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("AntiFall")
        if bv then bv:Destroy() end
    end
end

-- =========================
-- Dungeon clear
-- =========================
function Dungeon.handleClear()
    print("[Dungeon] Clear dungeon!")
    if Dungeon.autoReturn then
        TeleportService:Teleport(111989938562194, LocalPlayer)
    end
end

-- =========================
-- Main loop
-- =========================
function Dungeon.start()
    if running then return end
    running = true

    task.spawn(function()
        print("[Dungeon] Auto bắt đầu...")

        local emptyCount = 0
        while Dungeon.autoDungeon do
            local mob = Dungeon.getNearestMob()
            if mob then
                emptyCount = 0
                Dungeon.killMob(mob)
            else
                emptyCount += 1
                if emptyCount >= 3 then
                    Dungeon.handleClear()
                    break
                end
            end
            task.wait(0.5)
        end

        running = false
    end)
end

return Dungeon
