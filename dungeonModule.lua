-- dungeon.lua
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

-- Remote để attack
local AttackRemote = ReplicatedStorage:FindFirstChild("requestattack")

-- Boss -> Dungeon
local BossMap = {
    ["Bisonte Giuppture"] = "Dungeon1",
    ["Pot Hotspot"]       = "Dungeon2",
    ["Bearini"]           = "Dungeon3",
    -- thêm boss khác ở đây
}

-- Helper: match tên (case-insensitive, partial)
local function matchesName(realName, expected)
    if not realName or not expected then return false end
    return string.find(string.lower(realName), string.lower(expected), 1, true) ~= nil
end

-- Detect dungeon theo boss
function Dungeon.detectDungeon()
    for bossName, dungeonName in pairs(BossMap) do
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                if matchesName(v.Name, bossName) then
                    return dungeonName
                end
            end
        end
    end
    return "Unknown"
end

-- Tìm mob gần nhất
function Dungeon.getNearestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, v in ipairs(Workspace:GetChildren()) do
        local humanoid = v:FindFirstChild("Humanoid")
        local root = v:FindFirstChild("HumanoidRootPart")
        if v:IsA("Model") and humanoid and root and humanoid.Health > 0 then
            local d = (root.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end

    return nearest
end

-- Giữ player đứng trên mob + attack
local function attackMob(mob)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Dịch chuyển lên mob
    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

    -- AntiFall giữ y cố định
    if not hrp:FindFirstChild("AntiFall") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "AntiFall"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = hrp
    end

    -- Ưu tiên Remote attack
    if AttackRemote then
        AttackRemote:FireServer(mob)
    elseif mob:FindFirstChild("ClickDetector") then
        fireclickdetector(mob.ClickDetector)
    end
end

-- Kill 1 mob
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

-- Clear dungeon
function Dungeon.handleClear()
    print("[Dungeon] Clear dungeon!")
    if Dungeon.autoReturn then
        TeleportService:Teleport(111989938562194, LocalPlayer)
    end
end

-- Main loop
function Dungeon.start()
    if running then return end
    running = true

    task.spawn(function()
        local currentDungeon = Dungeon.detectDungeon()
        print("[Dungeon] Bạn đang ở:", currentDungeon)

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
