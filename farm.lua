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
            task.wait(0.2)
            if Farm.selectedMob then
                -- Tìm tất cả mob có cùng tên đang sống
                local mobs = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == Farm.selectedMob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        table.insert(mobs, v)
                    end
                end

                -- Nếu không có mob nào thì chờ 1s rồi check lại
                if #mobs == 0 then
                    task.wait(1)
                else
                    -- Lặp qua từng mob trong danh sách
                    for _, mob in ipairs(mobs) do
                        if not Farm.autofarm then break end
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- TP tới mob này
                            if Farm.autoTP then
                                pcall(function()
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,5)
                                end)
                            end

                            -- Đánh tới khi mob chết
                            repeat
                                task.wait(0.2)
                                if mob:FindFirstChild("ClickDetector") then
                                    pcall(function() fireclickdetector(mob.ClickDetector) end)
                                end
                            until not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0 or not Farm.autofarm
                        end
                    end
                end
            end
        end
        autofarmRunning = false
    end)
end

return Farm
