local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Require dungeonModule
local Dungeon = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/dungeonModule.lua"))()

local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()

-- GUI
local Window = OrionLib:MakeWindow({
    Name = "NOKM",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DungeonScript"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "",
    PremiumOnly = false
})

MainTab:AddLabel("Dungeon hiện tại: " .. Dungeon.detectDungeon())

MainTab:AddToggle({
    Name = "Auto Dungeons",
    Default = false,
    Callback = function(Value)
        Dungeon.autoDungeon = Value
        if Value then
            Dungeon.start()
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Return",
    Default = Dungeon.autoReturn,
    Callback = function(Value)
        Dungeon.autoReturn = Value
    end
})

-- Toggle Speed
    MainTab:AddToggle({
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
