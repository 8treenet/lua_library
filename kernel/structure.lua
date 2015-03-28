local M = {}

--创建链表
function M.newList()
    local obj = {}
    obj.head = nil
    obj.length = 0
    --链表插入数据
    function obj:insert(data)
        if self.head then
            local new = {data = data, _next = self.head}
            self.head = new
        else
            local new = {data = data, _next = nil}
            self.head = new
        end
        self.length = self.length + 1
    end
    
    --迭代链表 for data in obj:foreach do 
    function obj:foreach()
        local _next = self.head
        return function()
            if _next == nil then
                return nil
            end
            local ret = _next.data
            _next = _next._next
            return ret
        end
    end
    
    --删除链表某元素
    function obj:remove(data)
        local element = self.head
        local last = nil
        while element do
            if element.data == data then
                if last then
                    last._next = element._next
                else
                    self.head = element._next
                end
                self.length = self.length - 1
                break
            else
                last = element
                element = element._next
            end
        end
    end
    
    return obj
end

return M