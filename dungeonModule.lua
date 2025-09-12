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

-- Remote attack
local AttackRemote = ReplicatedStorage:FindFirstChild("RequestAttack")

-- =========================
-- Tìm mob gần nhất
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
            local d = (root.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
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
-- Kill mob cho tới khi chết
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
