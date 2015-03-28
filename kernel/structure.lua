local M = {}

function M.new()
    local obj = {}
    obj.head = nil
    
    function obj:insert(data)
        if self.head then
            local new = {data = data, _next = self.head}
            self.head = new
        else
            local new = {data = data, _next = nil}
            self.head = new
        end
    end
    
end

