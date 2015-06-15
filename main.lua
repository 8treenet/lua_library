require "CiderDebugger";----------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- @return

local width = display.contentWidth
local height = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

require("kernel.class")


function create1()
    local sb = {x=2}
    function sb:ctor(name)
        self.name = name
    end
    return sb
end

function create2(name)
    local dsb = class(create1())
    function dsb:ctor(name)
        self.super:ctor(name)
    end
    return dsb
end


local t1 = create2().new("t1sb")
local t2 = create2().new("t2sb")
print(t1.name)
print(t2.name)
