local Teleport = {}

-- Lấy character an toàn
local function getPlayerCharacter()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    task.wait(0.2)
    return char
end

-- Lấy danh sách object con trong 1 folder
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
        table.insert(list, "<Không có vị trí>")
    end
    return list
end

-- Các hàm trả về danh sách
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

-- Lấy part đích để TP
local function getTargetPart(targetModel)
    if not targetModel then return nil end
    if targetModel:IsA("BasePart") then return targetModel end
    return targetModel.PrimaryPart 
        or targetModel:FindFirstChild("HumanoidRootPart") 
        or targetModel:FindFirstChild("Base")
        or targetModel:FindFirstChildWhichIsA("BasePart")
end

-- Hàm chính để teleport
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

-- Quét toàn bộ boss có Humanoid và máu cao (WorldBoss / To To Sahur)
function Teleport.getBosses()
    local bosses, seen = {}, {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and obj:FindFirstChildOfClass("Humanoid")
        and obj:FindFirstChild("HumanoidRootPart") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hum.MaxHealth > 5000 and not seen[obj.Name] then
                table.insert(bosses, obj.Name)
                seen[obj.Name] = true
            end
        end
    end
    if #bosses == 0 then
        bosses = {"<Không có boss>"}
    end
    return bosses
end


return Teleport
