-- dungeon.lua
local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = true
local running = false

-- Map boss -> Dungeon name
local BossMap = {
    ["Bisonte Giuppture"] = "Dungeon1",
    ["Pot Hotspot"]       = "Dungeon2",
    ["Bearini"]          = "Dungeon3",
    -- thêm boss khác ở đây
}

-- Helper: so khớp tên (không phân biệt hoa thường, partial match)
local function nameMatches(realName, expected)
    return string.find(string.lower(realName), string.lower(expected), 1, true) ~= nil
end

-- Nhận diện dungeon theo boss
function Dungeon.detectDungeon()
    for bossName, dungeonName in pairs(BossMap) do
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                if nameMatches(v.Name, bossName) then
                    return dungeonName
                end
            end
        end
    end
    return "Unknown"
end

-- Tìm mob gần nhất (kể cả boss)
function Dungeon.getNearestMob()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") 
        and v:FindFirstChild("Humanoid") 
        and v:FindFirstChild("HumanoidRootPart") 
        and v.Humanoid.Health > 0 then
            local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end

    return nearest
end

-- Kill mob gần nhất
function Dungeon.killMob(mob)
    while Dungeon.autoDungeon 
    and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

                if not char.HumanoidRootPart:FindFirstChild("AntiFall") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "AntiFall"
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(0, math.huge, 0)
                    bv.Parent = char.HumanoidRootPart
                end
            end

            if mob:FindFirstChild("ClickDetector") then
                fireclickdetector(mob.ClickDetector)
            end
        end)
        task.wait(0.2)
    end

    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("AntiFall")
        if bv then bv:Destroy() end
    end
end

-- Khi dungeon clear
function Dungeon.handleClear()
    print("[Dungeon] Dungeon clear!")
    if Dungeon.autoReturn then
        game:GetService("TeleportService"):Teleport(111989938562194, game.Players.LocalPlayer)
    end
end

-- Vòng loop chính
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
                emptyCount = emptyCount + 1
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
