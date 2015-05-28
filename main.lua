require "CiderDebugger";-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- @return


local width = display.contentWidth
local height = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY


local base = function(filename)
    local b = {}
    function b:say()
        print("b")
    end
    local sb = {}
    sb.super = b
    setmetatable(sb, {__index=b})
    sb.__index = sb
    function sb:say()
        print("sb")
        self.super:say()
    end
    return sb
end

local obj = base("sd")
local th = {}
th.super=obj
function th:say()
    print("th")
    th.super:say()
end
setmetatable(th, obj)
th:say()
