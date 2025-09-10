-- dungeon.lua
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoReturn = false

-- Hàm Auto Dungeon (ví dụ giả lập, bạn sẽ thay logic riêng)
function Dungeon.startDungeon()
    task.spawn(function()
        while Dungeon.autoDungeon do
            print("[Dungeon] Auto Dungeon đang chạy...")
            -- TODO: Thêm code farm dungeon ở đây
            task.wait(2)
        end
    end)
end

-- Hàm Auto Return (ví dụ giả lập, bạn sẽ thay logic riêng)
function Dungeon.startReturn()
    task.spawn(function()
        while Dungeon.autoReturn do
            print("[Dungeon] Auto Return đang chạy...")
            -- TODO: Thêm code auto teleport về lobby
            task.wait(2)
        end
    end)
end

-- Tạo GUI nhỏ gọn
local Window = OrionLib:MakeWindow({
    Name = "H4xScripts",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DungeonScript"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Auto Dungeons",
    Default = false,
    Callback = function(Value)
        Dungeon.autoDungeon = Value
        if Value then
            Dungeon.startDungeon()
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Return",
    Default = false,
    Callback = function(Value)
        Dungeon.autoReturn = Value
        if Value then
            Dungeon.startReturn()
        end
    end
})

OrionLib:Init()
