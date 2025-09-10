-- loader.lua
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local BASE_URL = "https://raw.githubusercontent.com/doanhtuanthresh/lua/main/"

-- Map PlaceId → script cần load
local PlaceScripts = {
    [111989938562194] = "main.lua",      -- Lobby
    [90608986169653] = "dungeon.lua"     -- Dungeon
}

-- Hàm load script từ GitHub
local function loadScript(scriptName)
    local url = BASE_URL .. scriptName
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and result then
        print("[Loader] Đang chạy:", scriptName)
        loadstring(result)()
    else
        warn("[Loader] Không load được script:", scriptName)
    end
end

-- Lúc join game thì load ngay
if PlaceScripts[game.PlaceId] then
    loadScript(PlaceScripts[game.PlaceId])
else
    warn("[Loader] Không có script cho PlaceId:", game.PlaceId)
end

-- Khi teleport sang place khác → tự chạy lại loader.lua
TeleportService.TeleportInitFailed:Connect(function(_, result)
    warn("[Loader] Teleport fail:", result)
end)

TeleportService.LocalPlayerArrived:Connect(function(player)
    if player == LocalPlayer then
        task.wait(3) -- chờ load world
        loadstring(game:HttpGet(BASE_URL .. "loader.lua"))()
    end
end)
