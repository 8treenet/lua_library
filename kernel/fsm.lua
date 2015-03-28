local M = {}
M.seq = 1                           --Ai的递增ID
M.objPool = {}                      --ai角色列表
M.statePool =  {}                   --状态列表
M.msgList = {}                      --消息列表

function M.init()
    
end

function M.addObject(obj)           --为obj加入状态机
    obj.fsmID = tostring(M.seq)
    M.seq = M.seq + 1
    M.objPool[obj.fsmID] = obj
    obj.fsmStateList = {}           --多状态列表
    obj.fsmStateDataList ={}        --多状态数据
    
    function obj:deleteFsm()             --释放状态
       M.objPool[self.fsmID] = nil
       self.fsmStateList = nil
       self.fsmStateDataLis = nil
       self.fsmID =nil
    end
    
    --改变状态 状态类属, 状态名, 
    function obj:changeFsmState(key, stateName)         --改变状态
        if self.fsmStateList[key] ~= nil then
            self.fsmStateList[key]:quit(self)
        end
        self.fsmStateList[key] = M.statePool[stateName]
        self.fsmStateList[key]:start(self)
    end
    
    --改变状态数据 状态类属, 数据
    function obj:changeFsmStateData(key, data)
         self.fsmStateDataList[key] = data
    end
    
    --获取当前状态name 状态类属
    function obj:getFsmStatuName(key)
         return self.fsmStateList[key]:getName()
    end
    
    --获取当前状态数据
    function obj:getFsmStatuData(key)
         return self.fsmStateDataList[key]
    end
    
    --处理消息 消息id, 数据
    function obj:dispatchFsmMsg(MsgID, data)
        for key, state in pairs(self.fsmStateList) do
            state:dispatchFsmMsg(self, MsgID, data)
        end
    end
end

function M.update(deltaTime)         --更新状态机 时间增量
    for id, obj in pairs(M.objPool) do
        for key, state in pairs(obj.fsmStateList) do
            state:update(deltaTime, obj)
        end
    end
end

--加入状态到fsm 状态名，状态
function M.addState(stateName, state)
    M.statePool[stateName] = state
end

--发送消息 接受者id 消息id 数据 延迟时间
function M.sendMsg(recvFsmID, msgID, data, deltaTime)
    if deltaTime then
        local currentTime = system.getTimer()
        M.msgList[#M.msgList+1] = {deltaTime = currentTime + deltaTime,
                                   msgID = msgID,
                                   data = data}
    else
        local obj = M.objPool[recvFsmID]
        if obj then
            obj:dispatchFsmMsg(msgID, data)
        end
    end
end

function M.newBaseState()                   --基础状态类
    local state = {}
    
    function state:start(obj)
        error("未继承")
    end
    
    function state:quit(obj)
        error("未继承")
    end
    
    function state:update(deltaTime, obj)
        error("未继承")
    end
    
    function state:getName()
        error("未继承")
    end
    
    --处理消息 ai对象 消息id, 数据
    function state:dispatchFsmMsg(obj, MsgID, data)

    end
    
    return state
end

return M

