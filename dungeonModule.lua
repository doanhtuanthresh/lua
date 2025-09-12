local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = false

-- danh sách mob đã biết (cứ thêm keyword vào list này)
local MobList = {
    "tang",      -- bắt "Tang Tang Tang Tang Kelentang"
    "orc",
    "demon",
    "slime",
    "skeleton"
}

-- phát hiện dungeon hiện tại
function Dungeon.detectDungeon()
    local map = game.Workspace:FindFirstChild("Map")
    if map then
        return map.Name
    end
    return "Không xác định"
end

-- kiểm tra mob có khớp keyword trong list không
local function isMobInList(mobName)
    for _, keyword in ipairs(MobList) do
        if string.find(mobName:lower(), keyword:lower()) then
            return true
        end
    end
    return false
end

-- tìm mob gần nhất dựa trên list
local function getNearestMob()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end

    local hrp = player.Character.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and isMobInList(obj.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            if obj.Humanoid.Health > 0 then
                local mobHrp = obj.HumanoidRootPart
                local d = (hrp.Position - mobHrp.Position).Magnitude
                if d < dist then
                    nearest = obj
                    dist = d
                end
            end
        end
    end

    return nearest
end

-- teleport đến mob
local function tpToMob(mob)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- dịch ra sau lưng 3 stud
        player.Character.HumanoidRootPart.CFrame =
            mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
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
