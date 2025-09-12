-- dungeonModule.lua
local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = false

-- danh sách mob đã biết (cứ thêm tên mob vào list này)
local MobList = {
    "Tang Tang Tang Tang Kelentang",
    "Orc",
    "Demon",
    "SlimeBoss",
    "Skeleton"
}

-- phát hiện dungeon hiện tại
function Dungeon.detectDungeon()
    local map = game.Workspace:FindFirstChild("Map")
    if map then
        return map.Name
    end
    return "Không xác định"
end

-- tìm mob gần nhất dựa trên list
local function getNearestMob()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end

    local hrp = player.Character.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and table.find(MobList, obj.Name) and obj:FindFirstChild("HumanoidRootPart") then
            local mobHrp = obj.HumanoidRootPart
            local d = (hrp.Position - mobHrp.Position).Magnitude
            if d < dist then
                nearest = obj
                dist = d
            end
        end
    end

    return nearest
end

-- teleport đến mob
local function tpToMob(mob)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
    end
end

-- request attack mob
local function attackMob(mob)
    local remote = game.ReplicatedStorage:FindFirstChild("RequestAttack")
    if remote and mob and mob:FindFirstChild("HumanoidRootPart") then
        remote:FireServer(mob)
    end
end

-- vòng lặp auto dungeon
function Dungeon.start()
    spawn(function()
        while Dungeon.autoDungeon do
            local mob = getNearestMob()
            if mob then
                tpToMob(mob)
                attackMob(mob)
            end
            task.wait(0.5)
        end
    end)
end

return Dungeon
