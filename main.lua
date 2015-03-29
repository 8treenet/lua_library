require "CiderDebugger";-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- @return
local easeModule = require("kernel.ease")
local fsm = require("kernel.fsm")


local width = display.contentWidth
local height = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local obj = display.newImage( "Icon-60.png" )

obj.x = 0 
obj.y = display.contentHeight


--easeModule.addObject(obj, { x = 200, y = 0}, 1000)

local lastTime = system.getTimer( )
local function callbackFunction( event )
	local deltaTime = event.time - lastTime
	easeModule.update(deltaTime)
        fsm.update(deltaTime)
	lastTime = event.time
end
Runtime:addEventListener("enterFrame", callbackFunction )


local moveState = fsm.newBaseState()
function moveState:start(obj)
        obj:changeFsmStateData("statu", {isMove = false})
    end
    
function moveState:quit(obj)
    obj:changeFsmStateData("statu", nil)
end

math.randomseed(os.time())
function moveState:update(deltaTime, obj)
    local moveData = obj:getFsmStatuData("statu")
    if moveData.isMove == false then
        easeModule.addObject(obj, { x = math.random(width), 
        y = math.random(height)}, math.random(3000), function(target)
             target:changeFsmStateData("statu", {isMove = false})
        end)
        obj:changeFsmStateData("statu", {isMove = true})
    end
end

function moveState:getName()
    return "moveState"
end

fsm.addState("moveState", moveState)
fsm.addObject(obj)
obj:changeFsmState("statu", "moveState")

--处理消息 ai对象 消息id, 数据
function moveState:dispatchFsmMsg(obj, MsgID, data)
    
end


