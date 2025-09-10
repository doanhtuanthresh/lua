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
                -- Tìm tất cả mob còn sống
                local mobs = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == Farm.selectedMob 
                        and v:FindFirstChild("Humanoid") 
                        and v.Humanoid.Health > 0 
                        and v:FindFirstChild("HumanoidRootPart") then
                        table.insert(mobs, v)
                    end
                end

                if #mobs == 0 then
                    task.wait(1) -- nếu chưa có quái thì đợi spawn
                else
                    -- Lấy từng mob trong danh sách
                    for _, mob in ipairs(mobs) do
                        if not Farm.autofarm then break end
                        local hrp = mob:FindFirstChild("HumanoidRootPart")

                        -- Farm cho đến khi mob chết
                        while Farm.autofarm 
                            and mob 
                            and mob:FindFirstChild("Humanoid") 
                            and mob.Humanoid.Health > 0 do
                            
                            task.wait(0.2)
                            if hrp and Farm.autoTP then
                                -- luôn giữ vị trí gần mob
                                pcall(function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,5)
                                    end
                                end)
                            end

                            -- auto click
                            if mob:FindFirstChild("ClickDetector") then
                                pcall(function() fireclickdetector(mob.ClickDetector) end)
                            end
                        end
                    end
                end
            end
        end
        autofarmRunning = false
    end)
end

return Farm
