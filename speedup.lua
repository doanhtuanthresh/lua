local Speed = {}
local player = game.Players.LocalPlayer
local originalSpeed = nil  -- biến lưu tốc độ gốc

-- lấy humanoid
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- bật speed
function Speed.set(value)
    local hum = getHumanoid()
    -- nếu chưa lưu tốc độ gốc thì lưu lại
    if not originalSpeed then
        originalSpeed = hum.WalkSpeed
    end
    hum.WalkSpeed = value
end

-- reset về tốc độ gốc
function Speed.reset()
    local hum = getHumanoid()
    if originalSpeed then
        hum.WalkSpeed = originalSpeed
        originalSpeed = nil -- reset xong thì xoá để lần sau còn cập nhật đúng
    else
        hum.WalkSpeed = 16 -- fallback nếu vì lý do nào đó chưa lưu
    end
end

return Speed
