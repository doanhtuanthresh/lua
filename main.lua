if game.GameId == 7332711118 then
    local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
    
    -- import modules
    local Farm = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/farm.lua"))()
    local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()
    local ToTo = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/autoToToSahur.lua"))()
    local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/teleport.lua"))()

    local Window = OrionLib:MakeWindow({
        Name = "NOKM",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "OrionTest"
    })

    -----------------------------
    -- TAB: Auto Farm
    -----------------------------
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
            if Value then
                if Farm.selectedMob then
                    Farm.start()
                else
                    warn("[GUI] Bạn chưa chọn quái để farm.")
                end
            end
        end
    })

    -- Toggle Speed
    FarmTab:AddToggle({
        Name = "⚡ Tăng tốc",
        Default = false,
        Callback = function(Value)
            if Value then
                Speed.set(150)
            else
                Speed.reset()
            end
        end
    })

    -----------------------------
    -- TAB: Teleport
    -----------------------------
    local TeleTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "",
        PremiumOnly = false
    })

    -- Egg teleport
    local EggDropdown = TeleTab:AddDropdown({
        Name = "Chọn Egg",
        Default = "",
        Options = Teleport.getEggs(),
        Callback = function(v) _G.selEgg = v end
    })
    TeleTab:AddButton({
        Name = "🟢 Teleport tới Egg",
        Callback = function()
            Teleport.teleportTo(workspace.GameAssets.Eggs, _G.selEgg)
        end
    })

    -- Map teleport
    local MapDropdown = TeleTab:AddDropdown({
        Name = "Chọn Map",
        Default = "",
        Options = Teleport.getMaps(),
        Callback = function(v) _G.selMap = v end
    })
    TeleTab:AddButton({
        Name = "🟢 Teleport tới Map",
        Callback = function()
            Teleport.teleportTo(workspace.Maps, _G.selMap, true)
        end
    })

    -- Upgrade teleport
    local UpgDropdown = TeleTab:AddDropdown({
        Name = "Chọn Upgrade",
        Default = "",
        Options = Teleport.getUpgrades(),
        Callback = function(v) _G.selUpg = v end
    })
    TeleTab:AddButton({
        Name = "🟢 Teleport tới Upgrade",
        Callback = function()
            Teleport.teleportTo(workspace.GameAssets.WorldUpgrades, _G.selUpg)
        end
    })

    -----------------------------
    -- TAB: Auto To To Sahur
    -----------------------------
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

    -- Boss teleport dropdown
    local BossDropdown = TeleTab:AddDropdown({
        Name = "Chọn To To Sahur",
        Default = "",
        Options = Teleport.getBosses(),
        Callback = function(v) _G.selBoss = v end
    })

    TeleTab:AddButton({
        Name = "📍 Teleport tới Boss đã chọn",
        Callback = function()
            Teleport.teleportToBoss(_G.selBoss)
        end
    })

    -- 🟢 Khi boss mới xuất hiện
    Teleport.listenBossSpawn(function(boss)
        OrionLib:MakeNotification({
            Name = "Boss Spawn",
            Content = boss.Name .. " vừa xuất hiện!",
            Time = 3
        })

        local newList = Teleport.getBosses()
        pcall(function() BossDropdown:Refresh(newList, true) end)

        -- ⚡ Tự động teleport tới đúng map dựa vào tên boss
        Teleport.teleportBossByName(boss.Name)
    end)

    OrionLib:Init()
end
