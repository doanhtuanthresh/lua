-- main.lua
if game.GameId == 7332711118 then

    -- ===========================
    -- EARLY PATCH: LocalPlayerArrived
    -- ===========================
    -- Mục đích: tạo event giả TeleportService.LocalPlayerArrived
    -- và hook fallback để tránh lỗi "LocalPlayerArrived is not a valid member..."
    pcall(function()
        local TeleportService = game:GetService("TeleportService")

        -- 1) Tạo BindableEvent nếu chưa có
        if not TeleportService:FindFirstChild("LocalPlayerArrived") then
            local fake = Instance.new("BindableEvent")
            fake.Name = "LocalPlayerArrived"
            fake.Parent = TeleportService
            warn("[Patch] Created TeleportService.LocalPlayerArrived (BindableEvent)")
        end

        -- 2) Fallback: cố gắng hook __index của metatable để luôn trả về event giả khi truy cập
        local ok, mt = pcall(function() return getrawmetatable(TeleportService) end)
        if ok and mt then
            -- thả readonly, thay __index, rồi đặt lại readonly (nếu môi trường cho phép)
            pcall(function() setreadonly(mt, false) end)

            local oldIndex = mt.__index
            mt.__index = function(self, key)
                if key == "LocalPlayerArrived" then
                    -- trả về event có sẵn hoặc tạo mới
                    local existing = self:FindFirstChild("LocalPlayerArrived") or self:FindFirstChild("__fakeLocalPlayerArrived")
                    if existing then return existing end
                    local fake2 = Instance.new("BindableEvent")
                    fake2.Name = "__fakeLocalPlayerArrived"
                    fake2.Parent = self
                    return fake2
                end

                if type(oldIndex) == "function" then
                    return oldIndex(self, key)
                else
                    return rawget(self, key)
                end
            end

            pcall(function() setreadonly(mt, true) end)
            warn("[Patch] Hooked TeleportService __index for LocalPlayerArrived (fallback)")
        end
    end)

    -- ===========================
    -- Rest of your main.lua (Orion + modules)
    -- ===========================
    local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

    -- import Farm module 
    local Farm = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/farm.lua"))()

    -- import Speed module
    local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()

    -- import ToToSahur module
    local ToTo = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/autoToToSahur.lua"))()

    local Window = OrionLib:MakeWindow({
        Name = "NOKM",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "OrionTest"
    })

    local FarmTab = Window:MakeTab({
        Name = "Auto Farm",
        Icon = "",
        PremiumOnly = false
    })

    -- Dropdown chọn mob
    local MobDropdown
    local function createDropdown(options)
        MobDropdown = FarmTab:AddDropdown({
            Name = "Chọn quái để farm",
            Default = "",
            Options = options,
            Callback = function(Value)
                if Value == "<Không có quái>" then
                    Farm.selectedMob = nil
                else
                    Farm.selectedMob = Value
                end
                print("[GUI] Đã chọn quái:", tostring(Farm.selectedMob))
            end
        })
    end

    createDropdown(Farm.getMobList())

    -- Refresh mob list
    FarmTab:AddButton({
        Name = "🔄 Refresh danh sách quái",
        Callback = function()
            local newList = Farm.getMobList()
            local ok = pcall(function() MobDropdown:Refresh(newList, true) end)
            if not ok then
                createDropdown(newList) -- fallback
            end
            OrionLib:MakeNotification({
                Name = "Refresh",
                Content = "Đã cập nhật danh sách ("..#newList.." quái).",
                Time = 3
            })
        end
    })

    -- Toggle AutoFarm
    FarmTab:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Callback = function(Value)
            Farm.autofarm = Value
            if Value then Farm.start() end
        end
    })

    -- Toggle Speed
    FarmTab:AddToggle({
        Name = "⚡ Tăng tốc",
        Default = false,
        Callback = function(Value)
            if Value then
                Speed.set(150) -- chỉnh số tuỳ thích
            else
                Speed.reset()
            end
        end
    })

    -- Tab Auto To To Sahur
    local ToToTab = Window:MakeTab({
        Name = "Auto To To Sahur",
        Icon = "",
        PremiumOnly = false
    })

    ToToTab:AddToggle({
        Name = "Auto To To Sahur (WorldBoss)",
        Default = false,
        Callback = function(Value)
            ToTo.auto = Value
            if Value then
                ToTo.start()
                OrionLib:MakeNotification({
                    Name = "Auto To To Sahur",
                    Content = "Đang săn To To Sahur...",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Auto To To Sahur",
                    Content = "Đã tắt.",
                    Time = 3
                })
            end
        end
    })

    OrionLib:Init()
end
