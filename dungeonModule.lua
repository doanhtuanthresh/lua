local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = true
local running = false

-- Bảng định nghĩa mob/boss cho từng dungeon
local DungeonMap = {
    Dungeon1 = {
        Mobs = {"Gangster Footeerara", "Rhino Rhino", "ecco cavallo vir"},
        Boss = "Bisonte Giupptur"
    },
    Dungeon2 = {
        Mobs = {"tritrakatelas", "tang tang tang tang kelentang", "Alesio"},
        Boss = "Pothotspot"
    },
    Dungeon3 = {
        Mobs = {"ti ti ti ti ti ti sahur", "Bri biscus ticus", "espressonaa signorra"},
        Boss = "bearini"
    }
}

-- Nhận diện dungeon dựa theo mob/boss
function Dungeon.detectDungeon()
    for dungeonName, data in pairs(DungeonMap) do
        for _, mobName in ipairs(data.Mobs) do
            if workspace:FindFirstChild(mobName, true) then
                return dungeonName
            end
        end
        if data.Boss and workspace:FindFirstChild(data.Boss, true) then
            return dungeonName
        end
    end
    return "Unknown"
end

-- Lấy danh sách mob hiện có trong dungeon
function Dungeon.getMobList(currentDungeon)
    local list = {}
    local config = DungeonMap[currentDungeon]
    if not config then return list end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 then
                -- chỉ lấy mob thuộc dungeon hiện tại
                if table.find(config.Mobs, v.Name) or v.Name == config.Boss then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

-- Kill mob
function Dungeon.killMob(mob)
    while Dungeon.autoDungeon and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
            end
            if mob:FindFirstChild("ClickDetector") then
                fireclickdetector(mob.ClickDetector)
            end
        end)
        task.wait(0.2)
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

        while Dungeon.autoDungeon do
            local mobs = Dungeon.getMobList(currentDungeon)
            if #mobs == 0 then
                Dungeon.handleClear()
                break
            end

            for _, mob in ipairs(mobs) do
                if not Dungeon.autoDungeon then break end
                Dungeon.killMob(mob)
            end

            task.wait(0.5)
        end
        running = false
    end)
end

return Dungeon
