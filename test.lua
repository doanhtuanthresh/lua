-- loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/test.lua"))()

if game.PlaceId == 111989938562194 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({
        Name = "BrainrotScriptVN",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "OrionTest"
    })

    -- Values
    _G.autofarm = false
    _G.selectedMob = nil
    _G.autoTP = true
    local autofarmRunning = false

    -- Hàm tìm folder chứa quái (nếu có)
    local function findEnemiesFolder()
        local candidates = {"Enemies", "Enemy", "EnemiesFolder", "Mobs", "Monsters", "NPCs"}
        for _, name in ipairs(candidates) do
            local f = workspace:FindFirstChild(name)
            if f then return f end
        end
        return nil
    end

    local EnemiesFolder = findEnemiesFolder()

    -- Hàm lấy danh sách mob
    local function getMobList()
        local list = {}
        local source = EnemiesFolder and EnemiesFolder:GetDescendants() or workspace:GetDescendants()
        for _, v in ipairs(source) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v.Humanoid.Health > 0 and not table.find(list, v.Name) then
                    table.insert(list, v.Name)
                end
            end
        end
        return list
    end

    -- Autofarm
    local function startAutofarm()
        if autofarmRunning then return end
        autofarmRunning = true
        task.spawn(function()
            while _G.autofarm do
                task.wait(0.2)
                if _G.selectedMob then
                    local source = EnemiesFolder and EnemiesFolder:GetDescendants() or workspace:GetDescendants()
                    for _, v in ipairs(source) do
                        if not _G.autofarm then break end
                        if v:IsA("Model") and v.Name == _G.selectedMob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            local hrp = v:FindFirstChild("HumanoidRootPart")
                            if _G.autoTP and hrp then
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
                            until not v or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not _G.autofarm
                        end
                    end
                end
            end
            autofarmRunning = false
        end)
    end

    -- GUI
    local FarmTab = Window:MakeTab({
        Name = "Auto Farm",
        Icon = "",
        PremiumOnly = false
    })

    -- Dropdown chọn quái
    local MobDropdown
    local function createDropdown(options)
        MobDropdown = FarmTab:AddDropdown({
            Name = "Chọn quái để farm",
            Default = "",
            Options = options,
            Callback = function(Value)
                if Value == "<Không có quái>" then
                    _G.selectedMob = nil
                else
                    _G.selectedMob = Value
                end
                print("[GUI] Đã chọn quái:", tostring(_G.selectedMob))
            end
        })
    end

    createDropdown(getMobList())

    -- Refresh danh sách
    local function refreshDropdownAndNotify()
        local newList = getMobList()
        if #newList == 0 then newList = {"<Không có quái>"} end
        local ok = pcall(function() MobDropdown:Refresh(newList, true) end)
        if not ok then
            createDropdown(newList) -- fallback recreate
        end
        OrionLib:MakeNotification({
            Name = "Refresh",
            Content = "Đã cập nhật danh sách ("..#newList.." quái).",
            Time = 3
        })
    end

    FarmTab:AddButton({
        Name = "🔄 Refresh danh sách quái",
        Callback = refreshDropdownAndNotify
    })

    -- Toggle AutoFarm
    FarmTab:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Callback = function(Value)
            _G.autofarm = Value
            if Value then startAutofarm() end
        end
    })

    OrionLib:Init()
end
