-- Boss teleport dropdown
local BossDropdown = TeleTab:AddDropdown({
    Name = "Chọn To To Sahur",
    Default = "",
    Options = Teleport.getBosses(),
    Callback = function(v) _G.selBoss = v end
})

TeleTab:AddButton({
    Name = "📍 Teleport tới Boss đã chọn",
    Callback = function()
        Teleport.teleportToBoss(_G.selBoss)
    end
})

-- 🟢 Tự động cập nhật khi boss mới xuất hiện
Teleport.listenBossSpawn(function(boss)
    OrionLib:MakeNotification({
        Name = "Boss Spawn",
        Content = boss.Name .. " vừa xuất hiện!",
        Time = 3
    })
    local newList = Teleport.getBosses()
    pcall(function() BossDropdown:Refresh(newList, true) end)

    -- (tuỳ chọn) auto teleport luôn:
    -- Teleport.teleportToBoss(boss.Name)
end)
