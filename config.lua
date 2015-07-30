local x = display.pixelHeight / display.pixelWidth
local w = 650
application =
{

	content =
	{
		width = w,
		height = w * x, 
		scale = "letterBox",
		fps = 30,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
