local Speed = {}
local player = game.Players.LocalPlayer
local humanoid = nil

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

function Speed.set(value)
    humanoid = getHumanoid()
    humanoid.WalkSpeed = value
end

return Speed
