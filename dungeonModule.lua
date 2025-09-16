local Dungeon = {}
Dungeon.autoDungeon = false
Dungeon.autoPlayAgain = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local RequestAttack = ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.RequestAttack
local PlayAgainPressed = ReplicatedStorage.Packages.Knit.Services.DungeonService.RF.PlayAgainPressed
local ReplayVoteCast = ReplicatedStorage.Packages.Knit.Services.DungeonService.RE.ReplayVoteCast

-- tìm mob gần nhất (chỉ lấy NPC/quái, bỏ toàn bộ player)
local function getNearestMob()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid") 
        and obj:FindFirstChild("HumanoidRootPart") 
        and obj.Humanoid.Health > 0 
        and not Players:GetPlayerFromCharacter(obj) then
            local mobHrp = obj.HumanoidRootPart
            local d = (hrp.Position - mobHrp.Position).Magnitude
            if d < dist then
                nearest = obj
                dist = d
            end
        end
    end

    return nearest
end

-- request attack mob (dùng InvokeServer với CFrame mob)
local function attackMob(mob)
    if RequestAttack and mob and mob:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            RequestAttack:InvokeServer(mob.HumanoidRootPart.CFrame)
        end)
    end
end

-- teleport giữ sát mob + attack liên tục
local function farmMob(mob)
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart

    while Dungeon.autoDungeon 
    and mob 
    and mob:FindFirstChild("Humanoid") 
    and mob.Humanoid.Health > 0 do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            break
        end
        pcall(function()
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            if mobHrp then
                hrp.CFrame = mobHrp.CFrame * CFrame.new(0,0,-3)
                attackMob(mob)
            end
        end)
        task.wait(0.3)
    end
end

-- vòng lặp auto dungeon
function Dungeon.start()
    task.spawn(function()
        while Dungeon.autoDungeon do
            local mob = getNearestMob()
            if mob then
                farmMob(mob)
            else
                task.wait(0.5)
            end
            task.wait(0.1)
        end
    end)
end

-- bật auto play again (dùng sự kiện server)
function Dungeon.enableAutoPlayAgain()
    Dungeon.autoPlayAgain = true

    if not Dungeon._replayConn then
        Dungeon._replayConn = ReplayVoteCast.OnClientEvent:Connect(function(playerWhoTriggered)
            if Dungeon.autoPlayAgain then
                print("Dungeon kết thúc → auto chọn Play Again")
                pcall(function()
                    PlayAgainPressed:InvokeServer()
                end)
            end
        end)
    end
end

function Dungeon.disableAutoPlayAgain()
    Dungeon.autoPlayAgain = false
end

return Dungeon
