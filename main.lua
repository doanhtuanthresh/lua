-- main.lua
if game.PlaceId == 111989938562194 then
    local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
    
    -- import Farm module 
    local Farm = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/farm.lua"))()

    -- import Speed module
    local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()

    local Window = OrionLib:MakeWindow({
        Name = "BrainrotScriptVN",
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

    OrionLib:Init()
end
