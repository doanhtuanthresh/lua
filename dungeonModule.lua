-- dungeon.lua
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

-- Helper: so khớp tên (không phân biệt hoa thường, partial match)
local function nameMatches(realName, expected)
    return string.find(string.lower(realName), string.lower(expected), 1, true) ~= nil
end

-- Nhận diện dungeon dựa theo mob/boss
function Dungeon.detectDungeon()
    for dungeonName, data in pairs(DungeonMap) do
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                for _, mobName in ipairs(data.Mobs) do
                    if nameMatches(v.Name, mobName) then
                        return dungeonName
                    end
                end
                if data.Boss and nameMatches(v.Name, data.Boss) then
                    return dungeonName
                end
            end
        end
    end
    return "Unknown"
end

-- Lấy danh sách mob hiện có trong dungeon
function Dungeon.getMobList(currentDungeon)
    local mobs, bosses = {}, {}
    local config = DungeonMap[currentDungeon]
    if not config then return mobs, bosses end

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") 
        and v:FindFirstChild("Humanoid") 
        and v:FindFirstChild("HumanoidRootPart") 
        and v.Humanoid.Health > 0 then
            for _, mobName in ipairs(config.Mobs) do
                if nameMatches(v.Name, mobName) then
                    table.insert(mobs, v)
                end
            end
            if config.Boss and nameMatches(v.Name, config.Boss) then
                table.insert(bosses, v)
            end
        end
    end
    return mobs, bosses
end

-- Kill mob
function Dungeon.killMob(mob)
    while Dungeon.autoDungeon 
    and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Tele lên trên mob
                char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

                -- Giữ nhân vật không rơi
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

    -- mob chết => bỏ AntiFall để nhân vật về bình thường
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
            local mobs, bosses = Dungeon.getMobList(currentDungeon)

            if #mobs == 0 and #bosses == 0 then
                emptyCount = emptyCount + 1
                if emptyCount >= 3 then -- chờ 3 vòng trống liên tiếp để chắc chắn
                    Dungeon.handleClear()
                    break
                end
            else
                emptyCount = 0
                -- Ưu tiên mob thường trước, boss sau
                for _, mob in ipairs(mobs) do
                    if not Dungeon.autoDungeon then break end
                    Dungeon.killMob(mob)
                end
                for _, boss in ipairs(bosses) do
                    if not Dungeon.autoDungeon then break end
                    Dungeon.killMob(boss)
                end
            end
            task.wait(0.5)
        end
        running = false
    end)
end

return Dungeon
