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

    -- Tìm folder chứa mob (cố gắng nhiều tên khả dĩ)
    local function findEnemiesFolder()
        local candidates = {"Enemies", "Enemy", "EnemiesFolder", "Mobs", "Monsters", "NPCs"}
        for _, name in ipairs(candidates) do
            local f = workspace:FindFirstChild(name)
            if f then
                return f
            end
        end

        -- Nếu không thấy, thử tìm folder/model có child là Humanoid (fallback)
        for _, child in ipairs(workspace:GetChildren()) do
            if (child:IsA("Folder") or child:IsA("Model")) then
                for _, v in ipairs(child:GetChildren()) do
                    if v:FindFirstChild("Humanoid") then
                        return child
                    end
                end
            end
        end

        return nil
    end

    local EnemiesFolder = findEnemiesFolder()
    if EnemiesFolder then
        print("[AutoFarm] Found enemies folder:", EnemiesFolder:GetFullName())
    else
        OrionLib:MakeNotification({
            Name = "Warning",
            Content = "Không tìm thấy folder quái (Enemies). Hãy kiểm tra workspace.",
            Time = 5
        })
        print("[AutoFarm] Warning: Không tìm thấy folder Enemies trong workspace.")
    end

    -- Lấy danh sách tên quái (unique)
    local function getMobList()
        local list = {}
        EnemiesFolder = EnemiesFolder or findEnemiesFolder()
        if not EnemiesFolder then
            return list
        end

        for _, v in ipairs(EnemiesFolder:GetChildren()) do
            -- xác định là model có Humanoid
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                if not table.find(list, v.Name) then
                    table.insert(list, v.Name)
                end
            end
        end

        -- debug print
        if #list == 0 then
            print("[getMobList] Không tìm thấy mob nào trong:", EnemiesFolder:GetFullName())
        else
            print("[getMobList] Tìm thấy mobs:", table.concat(list, ", "))
        end

        return list
    end

    -- Autofarm (chỉ chạy 1 thread)
    local function startAutofarm()
        if autofarmRunning then return end
        autofarmRunning = true
        spawn(function()
            while _G.autofarm do
                task.wait(0.2)
                if not _G.selectedMob then
                    task.wait(0.5)
                else
                    for _, v in pairs((EnemiesFolder and EnemiesFolder:GetChildren()) or {}) do
                        if not _G.autofarm then break end
                        if v and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name == _G.selectedMob then
                            if _G.autoTP and v:FindFirstChild("HumanoidRootPart") then
                                pcall(function()
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                                end)
                            end

                            repeat
                                task.wait(0.1)
                                if v and v:FindFirstChild("HumanoidRootPart") then
                                    pcall(function()
                                        game.Players.LocalPlayer.Character.Humanoid:MoveTo(v.HumanoidRootPart.Position)
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                                    end)
                                end
                                if v and v:FindFirstChild("ClickDetector") then
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

    -- Dropdown (khởi tạo ban đầu)
    local MobDropdown = FarmTab:AddDropdown({
        Name = "Chọn quái để farm",
        Default = "",
        Options = (function()
            local t = getMobList()
            if #t == 0 then return {"<Chưa có quái>"} end
            return t
        end)(),
        Callback = function(Value)
            if Value == "<Chưa có quái>" or Value == "<No mobs found>" then
                _G.selectedMob = nil
            else
                _G.selectedMob = Value
            end
            print("[GUI] Đã chọn quái:", tostring(_G.selectedMob))
        end
    })

    -- Refresh function (dùng cho nút + tự động)
    local function refreshDropdownAndNotify()
        local newList = getMobList()
        if #newList == 0 then
            newList = {"<Chưa có quái>"}
        end

        -- pcall in case the dropdown object doesn't have Refresh
        local ok, err = pcall(function()
            MobDropdown:Refresh(newList, true)
        end)
        if not ok then
            -- fallback: recreate dropdown (nếu Refresh không tồn tại)
            print("[refreshDropdown] MobDropdown:Refresh lỗi, sẽ recreate.")
            MobDropdown = nil
            MobDropdown = FarmTab:AddDropdown({
                Name = "Chọn quái để farm",
                Default = "",
                Options = newList,
                Callback = function(Value)
                    if Value == "<Chưa có quái>" then _G.selectedMob = nil else _G.selectedMob = Value end
                    print("[GUI] Đã chọn quái:", tostring(_G.selectedMob))
                end
            })
        end

        OrionLib:MakeNotification({
            Name = "Refresh",
            Content = "Danh sách quái đã được cập nhật ("..tostring(#newList).." mục).",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end

    -- Nút Refresh
    FarmTab:AddButton({
        Name = "🔄 Refresh danh sách quái",
        Callback = function()
            refreshDropdownAndNotify()
        end
    })

    -- Auto refresh khi có child added/removed (nếu tìm được folder)
    if EnemiesFolder then
        local debounce = false
        local function onChanged()
            if debounce then return end
            debounce = true
            task.delay(1, function()
                EnemiesFolder = findEnemiesFolder() or EnemiesFolder
                refreshDropdownAndNotify()
                debounce = false
            end)
        end
        EnemiesFolder.ChildAdded:Connect(onChanged)
        EnemiesFolder.ChildRemoved:Connect(onChanged)
    end

    -- Toggle Auto Farm
    FarmTab:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Callback = function(Value)
            _G.autofarm = Value
            if Value then
                startAutofarm()
            end
            print("[GUI] AutoFarm =", Value)
        end
    })

    OrionLib:Init()
end
