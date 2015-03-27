require "CiderDebugger";-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local easeModule = require("kernel.ease")


local obj = display.newImage( "Icon-60.png" )

obj.x = 0 
obj.y = display.contentHeight


local ease = easeModule.new(obj, { x = 200, y = 0}, 1000)

local lastTime = system.getTimer( )
local function callbackFunction( event )
	local deltaTime = event.time - lastTime
	local ret = ease:enter(deltaTime)
	lastTime = event.time
end
Runtime:addEventListener("enterFrame", callbackFunction )
print("dsb")