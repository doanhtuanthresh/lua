local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Dungeon = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/dungeonModule.lua"))()
local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/speedup.lua"))()

local HttpService = game:GetService("HttpService")
local configPath = "DungeonScript/config.json"

-- Hàm đọc config nếu tồn tại
local function loadConfig()
    if isfile(configPath) then
        local data = HttpService:JSONDecode(readfile(configPath))
        return {
            autoDungeon = data.autoDungeon or false,
            autoPlayAgain = data.autoPlayAgain or false
        }
    else
        return {
            autoDungeon = false,
            autoPlayAgain = false
        }
    end
end

-- Hàm lưu config mỗi khi thay đổi
local function saveConfig(autoDungeon, autoPlayAgain)
    local data = {
        autoDungeon = autoDungeon,
        autoPlayAgain = autoPlayAgain
    }
    writefile(configPath, HttpService:JSONEncode(data))
end

-- Đọc config ban đầu
local config = loadConfig()

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
    Default = config.autoDungeon,
    Callback = function(Value)
        Dungeon.autoDungeon = Value
        saveConfig(Value, config.autoPlayAgain) -- lưu lại
        config.autoDungeon = Value
        if Value then
            Dungeon.start()
        end
    end
})

-- Toggle Auto Replay Dungeon
MainTab:AddToggle({
    Name = "Auto Play Again",
    Default = config.autoPlayAgain,
    Callback = function(Value)
        saveConfig(config.autoDungeon, Value) -- lưu lại
        config.autoPlayAgain = Value
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
            Speed.set(150)
        else
            Speed.reset()
        end
    end
})

-- Tự bật lại trạng thái nếu config đang bật
if config.autoDungeon then
    Dungeon.autoDungeon = true
    Dungeon.start()
end

if config.autoPlayAgain then
    Dungeon.enableAutoPlayAgain()
end

OrionLib:Init()
