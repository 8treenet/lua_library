
function class(super)
    local obj = {}
    obj.super = super
    setmetatable(obj, {__index = super})
    function obj.new(...)
        obj:ctor(...)
        return obj
    end
    return obj
end
