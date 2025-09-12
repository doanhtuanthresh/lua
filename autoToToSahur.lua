local ToTo = {}
ToTo.auto = false
local running = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Remote services
local RequestTeleport = ReplicatedStorage.Packages.Knit.Services.TeleportService.RF.RequestTeleport
local Transition = ReplicatedStorage.Packages.Knit.Services.NotificationService.RE.Transition

-- Danh sách map có To To Sahur (bạn tự add vào đây)
ToTo.Maps = {
    "Larila Desert",
    "Tralalero Ocean",
    "Mount Ambalabu",
    "Chicleteiramania",
    "Nuclearo Core",
    "Udin Dinlympus",
    "Glorbo Heights",
    "Brainrot Abyss",
    "Bombardino Sewer",
    -- thêm map khác ...
}

-- Tìm toàn bộ boss "To To Sahur" trong map hiện tại
local function getAllBosses()
    local bosses = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
            and obj:FindFirstChild("Humanoid")
            and obj:FindFirstChild("HumanoidRootPart") then
            local hum = obj.Humanoid
            if string.find(string.lower(obj.Name), "to to sahur")
                and hum.Health > 0
                and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                table.insert(bosses, obj)
            end
        end
    end
    return bosses
end

-- Tìm boss gần nhất trong map hiện tại
local function getNearestBoss()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local nearest, dist = nil, math.huge
    for _, boss in ipairs(getAllBosses()) do
        local d = (boss.HumanoidRootPart.Position - hrp.Position).Magnitude
        if d < dist then
            nearest = boss
            dist = d
        end
    end
    return nearest
end

-- Farm boss hiện tại
local function farmBoss(boss)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local hum = boss:FindFirstChild("Humanoid")
    if not hum then return end

    while ToTo.auto and hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead do
        pcall(function()
            if boss:FindFirstChild("HumanoidRootPart") then
                -- dịch chuyển sát boss
                hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

                -- tấn công
                local remote = ReplicatedStorage:FindFirstChild("RequestAttack")
                if remote then
                    remote:FireServer(boss)
                elseif boss:FindFirstChild("ClickDetector") then
                    fireclickdetector(boss.ClickDetector)
                end
            end
        end)
        task.wait(0.3)
    end
end

-- Teleport tới map chỉ định
local function goToMap(mapName)
    print("[ToTo] Teleporting to:", mapName)
    RequestTeleport:InvokeServer(mapName)

    -- Chờ event Transition confirm load map
    local done = false
    local conn
    conn = Transition.OnClientEvent:Connect(function(data)
        if typeof(data) == "table" and data.Text and string.find(data.Text, mapName) then
            done = true
            conn:Disconnect()
        end
    end)
    repeat task.wait() until done
    task.wait(2) -- đợi map load hẳn
end

-- Main loop: đi hết map, farm boss, lặp lại
function ToTo.start()
    if running then return end
    running = true

    task.spawn(function()
        while ToTo.auto do
            for _, map in ipairs(ToTo.Maps) do
                if not ToTo.auto then break end
                goToMap(map)

                local boss = getNearestBoss()
                if boss then
                    farmBoss(boss)
                end
            end
            task.wait(5) -- hết vòng, chờ boss spawn lại
        end
        running = false
    end)
end

return ToTo
