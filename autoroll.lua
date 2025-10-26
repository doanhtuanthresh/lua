-- autoroll.lua
local AutoRoll = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollRemote = ReplicatedStorage.Packages.Knit.Services.MedalService.RF.Roll

AutoRoll.enabled = false
AutoRoll.targetMedal = nil
AutoRoll.delay = 2 -- giây

function AutoRoll.start()
    spawn(function()
        while AutoRoll.enabled do
            if RollRemote and AutoRoll.targetMedal ~= nil then
                pcall(function()
                    RollRemote:InvokeServer(AutoRoll.targetMedal)
                end)
            end
            task.wait(AutoRoll.delay)
        end
    end)
end

return AutoRoll
