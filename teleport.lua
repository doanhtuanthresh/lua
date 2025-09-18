local Teleport = {}

-- 📍 Bảng ánh xạ TÊN boss → vị trí map chứa boss đó
local BossLocations = {
    ["To To To To To To To Sahur"]                     = CFrame.new(513, 105, -77),       -- Larila Desert
    ["To To To To To To To To Sahur"]                  = CFrame.new(-287, 109, -1866),    -- Tralalero Ocean
    ["To To To To To To To To To Sahur"]               = CFrame.new(-1531, 147, 1375),    -- Mount Ambalabu
    ["To To To To To To To To To To Sahur"]             = CFrame.new(-2640, 113.7, -899),  -- Chicleteiramania
    ["To To To To To To To To To To To Sahur"]           = CFrame.new(-2200, 291, -3756),   -- Nuclearo Core
    ["To To To To To To To To To To To To Sahur"]         = CFrame.new(1294, -41, -4262),    -- Udin Dinlympus
    ["To To To To To To To To To To To To To Sahur"]       = CFrame.new(-3945, 51, 934),      -- Glorbo Heights
    ["To To To To To To To To To To To To To To Sahur"]     = CFrame.new(-1788, 199, 5011),    -- Brainrot Abyss
    ["To To To To To To To To To To To To To To To Sahur"]   = CFrame.new(-3607, 197, 2246),    -- Bombardino Sewer
    ["To To To To To To To To To To To To To To To To Sahur"] = CFrame.new(-6919, 75, -2238),   -- Goaaat Galaxy
}
-- 🧍 Lấy character an toàn
local function getPlayerCharacter()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    task.wait(0.2)
    return char
end

-- 🗺️ Lấy danh sách object con trong 1 folder
local function getLocations(folder)
    local list = {}
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(list, obj.Name)
            end
        end
    end
    if #list == 0 then
        list = {"<Không có vị trí>"}
    end
    return list
end

-- 🗺️ Các hàm trả về danh sách
function Teleport.getEggs()
    return getLocations(workspace:WaitForChild("GameAssets"):WaitForChild("Eggs"))
end

function Teleport.getMaps()
    return getLocations(workspace:WaitForChild("Maps"))
end

function Teleport.getUpgrades()
    return getLocations(workspace:WaitForChild("GameAssets"):WaitForChild("WorldUpgrades"))
end

function Teleport.getVendingMachines()
    return getLocations(workspace:WaitForChild("GameAssets"):WaitForChild("VendingMachines"))
end

function Teleport.getRebirthModels()
    return getLocations(workspace:WaitForChild("GameAssets"):WaitForChild("RebirthModels"))
end

-- 📍 Lấy part đích để TP
local function getTargetPart(targetModel)
    if not targetModel then return nil end
    if targetModel:IsA("BasePart") then return targetModel end
    return targetModel.PrimaryPart 
        or targetModel:FindFirstChild("HumanoidRootPart") 
        or targetModel:FindFirstChild("Base")
        or targetModel:FindFirstChildWhichIsA("BasePart")
end

-- ⚡ Teleport chung tới bất kỳ object nào
function Teleport.teleportTo(folder, name, useSpawn)
    if not folder or not name or name == "<Không có vị trí>" then return end
    local model = folder:FindFirstChild(name)
    if not model then return end

    local target = model
    if useSpawn and model:FindFirstChild("Spawn") and model.Spawn:IsA("BasePart") then
        target = model.Spawn
    end

    local targetPart = getTargetPart(target)
    local char = getPlayerCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") and targetPart then
        char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
    end
end

-- 📋 Lấy danh sách tất cả To To Sahur hiện có trong workspace
function Teleport.getBosses()
    local list = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") 
        and obj:FindFirstChildOfClass("Humanoid")
        and string.find(obj.Name, "To To Sahur") then
            table.insert(list, obj.Name)
        end
    end
    if #list == 0 then
        list = {"<Không có boss>"}
    end
    return list
end

-- 📍 Teleport trực tiếp tới boss đang hiện diện trong workspace (nếu cùng map)
function Teleport.teleportToBoss(name)
    if not name or name == "<Không có boss>" then return end
    local boss = workspace:FindFirstChild(name)
    if not boss then return end
    local part = getTargetPart(boss)
    if part then
        local char = getPlayerCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, 15)
        end
    end
end

-- ⚡ Teleport tới boss dựa vào tên (kể cả chưa được stream về workspace)
function Teleport.teleportBossByName(name)
    local cf = BossLocations[name]
    if not cf then
        warn("Không tìm thấy vị trí boss: " .. tostring(name))
        return
    end
    local char = getPlayerCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf + Vector3.new(0, 5, 0)
    end
end

-- 🟢 Theo dõi boss mới được stream về
function Teleport.listenBossSpawn(onSpawn)
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") 
        and obj:FindFirstChildOfClass("Humanoid")
        and string.find(obj.Name, "To To Sahur") then
            task.wait(1)
            onSpawn(obj)
        end
    end)
end

return Teleport
