local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = false

-- tìm mob gần nhất (chỉ lấy NPC/quái, bỏ toàn bộ player)
local function getNearestMob()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end

    local hrp = player.Character.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid") 
        and obj:FindFirstChild("HumanoidRootPart") 
        and obj.Humanoid.Health > 0 
        and not game.Players:GetPlayerFromCharacter(obj) -- loại bỏ player
        then
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

-- request attack mob
local function attackMob(mob)
    local remote = game.ReplicatedStorage:FindFirstChild("RequestAttack")
    if remote and mob and mob:FindFirstChild("HumanoidRootPart") then
        remote:FireServer(mob)
    end
end

-- teleport giữ sát mob + attack liên tục
local function farmMob(mob)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end

    local hrp = char.HumanoidRootPart

    while Dungeon.autoDungeon 
    and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        pcall(function()
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            if mobHrp then
                -- TP giữ khoảng cách 3 stud sau lưng mob
                hrp.CFrame = mobHrp.CFrame * CFrame.new(0,0,-3)
                -- Tấn công
                attackMob(mob)
            end
        end)
        task.wait(0.2)
    end
end

-- vòng lặp auto dungeon
function Dungeon.start()
    task.spawn(function()
        while Dungeon.autoDungeon do
            local mob = getNearestMob()
            if mob then
                farmMob(mob)
            end
            task.wait(0.3)
        end
    end)
end

return Dungeon
