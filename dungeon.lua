local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Require dungeonModule
local Dungeon = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/dungeonModule.lua"))()
local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()

-- Biến toàn cục lưu trạng thái
getgenv().AutoDungeonState = getgenv().AutoDungeonState or false
getgenv().AutoPlayAgainState = getgenv().AutoPlayAgainState or false

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

-- Toggle Auto Dungeons
MainTab:AddToggle({
    Name = "Auto Dungeons",
    Default = getgenv().AutoDungeonState,
    Callback = function(Value)
        getgenv().AutoDungeonState = Value
        Dungeon.autoDungeon = Value
        if Value then
            Dungeon.start()
        end
    end
})

-- Toggle Auto Replay Dungeon
MainTab:AddToggle({
    Name = "Auto Play Again",
    Default = getgenv().AutoPlayAgainState,
    Callback = function(Value)
        getgenv().AutoPlayAgainState = Value
        if Value then
            Dungeon.enableAutoPlayAgain()
        else
            Dungeon.disableAutoPlayAgain()
        end
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

-- Tự bật lại nếu đã bật từ lần trước
if getgenv().AutoDungeonState then
    Dungeon.autoDungeon = true
    Dungeon.start()
end

if getgenv().AutoPlayAgainState then
    Dungeon.enableAutoPlayAgain()
end

OrionLib:Init()
