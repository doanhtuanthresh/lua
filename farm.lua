local Farm = {}

Farm.autofarm = false
Farm.selectedMob = nil
Farm.autoTP = true
local autofarmRunning = false

-- Lấy danh sách mob
function Farm.getMobList()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 and not table.find(list, v.Name) then
                table.insert(list, v.Name)
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
        while Farm.autofarm do
            task.wait(0.5)
            -- tìm mob mới mỗi vòng
            local targetMob = nil
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == Farm.selectedMob 
                and v:FindFirstChild("Humanoid") 
                and v.Humanoid.Health > 0 then
                    targetMob = v
                    break
                end
            end

            -- nếu tìm thấy thì TP đến mob đó
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local hrp = targetMob.HumanoidRootPart
                while Farm.autofarm and targetMob 
                and targetMob:FindFirstChild("Humanoid") 
                and targetMob.Humanoid.Health > 0 do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,5)
                        end
                        if targetMob:FindFirstChild("ClickDetector") then
                            fireclickdetector(targetMob.ClickDetector)
                        end
                    end)
                    task.wait(0.2)
                end
                -- hết vòng lặp này => mob chết => quay lại while ngoài để tìm mob mới
            end
        end
        autofarmRunning = false
    end)
end


return Farm
