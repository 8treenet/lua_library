local M = {}
M.seq = 1                           --Ai的递增ID
M.objPool = {}                      --ai列表
function M.init()
    
end

function M.addObject(Obj)           --为obj加入状态机
    local ai = {}
    ai.id = M.seq
    M.seq = M.seq + 1
    M.objPool[ai.id] = Obj
    function ai:free()
       M.objPool[self.id] = nil
    end
    function ai:getID()
        return self.id
    end
    Obj._ai = ai
end

function M.update(deltaTime)         --更新状态机 时间增量
    
end

function M.newBaseState()
    local state = {}
    
    function state:start()
        error("未继承")
    end
    
    function state:quit()
        error("未继承")
    end
    
    function state:update()
        
    end
    return state
end

return M

