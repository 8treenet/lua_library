--function create1()
--    local a = {x=2}
--    function a:ctor(name)
--        self.name = name
--    end
--    return a
--end
--
--function create2(name)
--    local b = class(create1())
--    function b:ctor(name)
--        self.super:ctor(name)
--    end
--    return b
--end
--
--
--local t1 = create2().new("a")
--local t2 = create2().new("b")
--print(t1.name)
--print(t2.name)

function class(super)
    local obj = {}
    obj.parent = parent
    setmetatable(obj, {__index = parent})
    function obj.new(...)
        obj:ctor(...)
        return obj
    end
    return obj
end
