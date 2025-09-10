-- loader.lua
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId

-- Link gốc GitHub của bạn (sửa lại nếu khác)
local BASE_URL = "https://raw.githubusercontent.com/doanhtuanthresh/lua/main/"

-- Map PlaceId → script cần load
local PlaceScripts = {
    [111989938562194] = "main.lua",      -- Lobby chính
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

-- Chạy đúng script theo PlaceId
if PlaceScripts[PlaceId] then
    loadScript(PlaceScripts[PlaceId])
else
    warn("[Loader] Không có script cho PlaceId:", PlaceId)
end
