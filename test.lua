-- loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/test.lua"))()

if game.PlaceId == 111989938562194 then
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
    local Window = OrionLib:MakeWindow({Name = "BrainrotScriptVN", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

    --Values
    _G.autofarm = false
    _G.selectedMob = nil
    _G.autoTP = true

    --Functions
    function autofarm()
        spawn(function() -- chạy song song
            while task.wait() do
                if _G.autofarm and _G.selectedMob ~= nil then
                    for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") 
                        and v.Humanoid.Health > 0 
                        and v.Name == _G.selectedMob then -- chỉ đánh quái được chọn
                            
                            if _G.autoTP then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                            end

                            repeat
                                task.wait()
                                game.Players.LocalPlayer.Character.Humanoid:MoveTo(v.HumanoidRootPart.Position)
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                                if v:FindFirstChild("ClickDetector") then
                                    fireclickdetector(v.ClickDetector)
                                end
                            until v.Humanoid.Health <= 0 or not _G.autofarm
                        end
                    end
                end
            end
        end)
    end

    --Tabs
    local FarmTab = Window:MakeTab({
        Name = "Auto Farm",
        Icon = "",
        PremiumOnly = false
    })

    -- Dropdown để chọn quái
    local mobs = {}
    for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
        if table.find(mobs, v.Name) == nil then
            table.insert(mobs, v.Name)
        end
    end

    FarmTab:AddDropdown({
        Name = "Chọn quái để farm",
        Default = "",
        Options = mobs,
        Callback = function(Value)
            _G.selectedMob = Value
            print("Đã chọn quái:", Value)
        end    
    })

    -- Toggle Auto Farm
    FarmTab:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Callback = function(Value)
            _G.autofarm = Value
            if Value then
                autofarm()
            end
        end    
    })

    OrionLib:Init()
end

