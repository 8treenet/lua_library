require "CiderDebugger";-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- @return
local easeModule = require("kernel.ease")
easeModule.init()

local width = display.contentWidth
local height = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local obj = display.newImage( "Icon-60.png" )
obj.x = 0 
obj.y = display.contentHeight

local lastTime = system.getTimer( )
local function callbackFunction( event )
	local deltaTime = event.time - lastTime
	easeModule.update(deltaTime)
	lastTime = event.time
end
Runtime:addEventListener("enterFrame", callbackFunction )



