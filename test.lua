-- loadstring(game:HttpGet("https://raw.githubusercontent.com/doanhtuanthresh/lua/main/test.lua"))()

if game.PlaceId == 111989938562194 then
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "BrainrotScriptVN", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})


local Tab = Window:MakeTab({
	Name = "Tab 1",
	Icon = "",
	PremiumOnly = false
})




end
OrionLib:Init()
