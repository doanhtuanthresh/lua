-- speedup.lua
local Speed = {}
local player = game.Players.LocalPlayer

-- lấy humanoid
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- bật speed
function Speed.set(value)
    local hum = getHumanoid()
    hum.WalkSpeed = value
end

-- reset về mặc định (Roblox mặc định là 16)
function Speed.reset()
    local hum = getHumanoid()
    hum.WalkSpeed = 16
end

return Speed
