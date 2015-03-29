local M = {}

function M.init()
    local structure = require("kernel.structure")
    M.easeList = structure.newList()     --插值列表
end

function M.addObject(obj, table, time, successfun, from)              --插值对象，参数列表，时间毫秒，是否是增量数据
	local ease = {}
	ease.target = obj								--目标对象
	ease.time = time or 1                           --共用时间
	ease.table = table                              --参数
	ease.overTime = time or 1                       --结束的时间
	ease.src = {}                                   --源目标对象参数
        ease.successfun = successfun
	for k, v in pairs(table) do
		ease.src[k] = obj[k]
		if (from) then                              --如果是增量，为参数加上增量数据
			ease.table[k] = ease.src[k] + ease.table[k]
		end
	end
	function ease:enter( deltaTime )    			--增量时间     完成返回真,
		if (self.overTime > 0) then
			self:_update(deltaTime)
			self.overTime = self.overTime - deltaTime
			if (self.overTime <= 33.5) then          --小于33毫秒直接计算
				self:_update(ease.overTime)
				ease.overTime = 0
                                ease.successfun(ease.target)
				return true
			end
		end
		return false
	end
	function ease:_update( deltaTime )               --根据时间增量做数值变换
			for k, v in pairs(ease.table) do
				local move = (v - self.src[k]) / ease.time * deltaTime
				self.target[k] = self.target[k]+move
			end
	end
        M.easeList:insert(ease)
end

function M.update(deltaTime)
    local deleteData = {}
    for element in M.easeList:foreach() do
        local ret = element:enter(deltaTime)
        if ret == true then
            deleteData[#deleteData+1] = element
        end
    end
    for i = 1, #deleteData do
        M.easeList:remove(deleteData[i])
    end
end

M.init()

return M