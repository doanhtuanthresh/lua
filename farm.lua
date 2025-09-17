local Farm = {}

Farm.autofarm = false
Farm.selectedMob = nil
local autofarmRunning = false

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

-- Lấy MonsterService (Knit)
local function getMonsterService()
    local rs = game:GetService("ReplicatedStorage")
    local knit = rs:WaitForChild("Packages"):WaitForChild("Knit", 5)
    if not knit then return nil end
    local service = knit:WaitForChild("Services"):FindFirstChild("MonsterService")
    return service and service:FindFirstChild("RF")
end

-- Lấy danh sách mob khả dụng
function Farm.getMobList()
    local list, seen = {}, {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChildOfClass("Humanoid")
        and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hum.WalkSpeed > 0 and not seen[v.Name] then
                table.insert(list, v.Name)
                seen[v.Name] = true
            end
        end
    end
    if #list == 0 then
        list = {"<Không có quái>"}
    end
    return list
end

-- Auto farm
function Farm.start()
    if autofarmRunning then return end
    autofarmRunning = true

    task.spawn(function()
        if not Farm.selectedMob then
            warn("[Farm] Bạn chưa chọn quái để farm.")
            autofarmRunning = false
            return
        end

        local monsterService = getMonsterService()
        if not monsterService or not monsterService:FindFirstChild("RequestAttack") then
            warn("[Farm] Không tìm thấy MonsterService hoặc RequestAttack.")
            autofarmRunning = false
            return
        end

        while Farm.autofarm do
            task.wait(0.5)

            -- Tìm mob được chọn
            local targetMob
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model")
                and v.Name == Farm.selectedMob
                and v:FindFirstChildOfClass("Humanoid") then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if hum.Health > 0 then
                        targetMob = v
                        break
                    end
                end
            end

            if targetMob and targetMob.PrimaryPart then
                local char = getPlayerCharacter()
                if char and char.PrimaryPart then
                    -- Teleport tới gần mob
                    char.PrimaryPart.CFrame = targetMob.PrimaryPart.CFrame * CFrame.new(0,0,15)

                    -- Tấn công liên tục tới khi mob chết hoặc dừng toggle
                    while Farm.autofarm
                    and targetMob
                    and targetMob.Parent
                    and targetMob:FindFirstChildOfClass("Humanoid")
                    and targetMob:FindFirstChildOfClass("Humanoid").Health > 0 do
                        pcall(function()
                            monsterService.RequestAttack:InvokeServer(targetMob.PrimaryPart.CFrame)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end

        autofarmRunning = false
    end)
end

return Farm
