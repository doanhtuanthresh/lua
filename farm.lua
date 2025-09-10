-- farm.lua
local Farm = {}

Farm.autofarm = false
Farm.selectedMob = nil
Farm.autoTP = true
local autofarmRunning = false

-- lấy danh sách mob
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

-- auto farm loop
function Farm.start()
    if autofarmRunning then return end
    autofarmRunning = true
    task.spawn(function()
        while Farm.autofarm do
            task.wait(0.2)
            if Farm.selectedMob then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if not Farm.autofarm then break end
                    if v:IsA("Model") and v.Name == Farm.selectedMob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        if Farm.autoTP and hrp then
                            pcall(function()
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,5)
                            end)
                        end
                        repeat
                            task.wait(0.1)
                            if hrp then
                                pcall(function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("Humanoid") then
                                        char.Humanoid:MoveTo(hrp.Position)
                                        char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,5)
                                    end
                                end)
                            end
                            if v:FindFirstChild("ClickDetector") then
                                pcall(function() fireclickdetector(v.ClickDetector) end)
                            end
                        until not v or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not Farm.autofarm
                    end
                end
            end
        end
        autofarmRunning = false
    end)
end

return Farm
