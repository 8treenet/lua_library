----包格式{seq,id,list={数据列表}}   seq id固定格式，，数据列表通过自定义protocol回调模块组或解
local M = {}
local socket = require( "socket" )
local math = require( "math" )
local string = require( "string" )
local pub = require( "kernel.public")
local stream = require( "kernel.stream")
local heartSecond = 35         					--心跳的时间          
M.connect = false                               --当前是否连接

function M.init(parameter, protocol)                  --初始化 参数地址,{addr="127.0.0.1", port= 9527}
	M._go = coroutine.create(M._start)				 ---，协议回掉模块 实现protocol.encode和 protocol.decode
	M._parameter = parameter
	M._protocol = protocol
	M._timeout = os.time(  )
	M._heartPackage =  protocol.getHeartPackage()
end

function M.reboot(  )                                   --重连
	M._go = coroutine.create(M._start)
	M._timeout = os.time(  )
	M._rQueue = {}                                        --读队列
	M._wQueue = {}                                        --写队列
	M._recvBuf = ""                                       --读缓冲区
	M._writeBuf = ""                                      --写缓冲区
	M._sequence = 0                                       --seq
	M.connect =  false
end

function M.resume( )                                      --循环调用呗  返回"ok"正常， 断开＝ nil
	if (M._go ~= nil) then                                
		local temp, ret = coroutine.resume(M._go, M._parameter)
		return ret          
	end
	return nil
end

function M.send( T)                                    --发送包。。协议回调模块把元表组包
	-- body
	M._wQueue[#M._wQueue+1] = T
end

function M.recv( seq )                                     --接收包。。
	-- body                                                --如果有SEQ 则接收指定的seq包
	--pub.printTable(M._rQueue)
	seq = seq or 0
	if (#M._rQueue < 1) then
		return nil
	else
		local pos = 0
		for i=1, #M._rQueue do
			if (M._rQueue[i].seq == seq) then
				pos = i
				break
			end
		end
		if (pos ~= 0) then
			return table.remove( M._rQueue, pos )
		else
			return nil
		end
	end
end

function M.getSequence(  )
	M._sequence = M._sequence+1
	if (M._sequence >= 1294967296) then
		M._sequence = 1
	end
	return M._sequence
end
----------------------------------------------------以下函数是内部函数和内部变量----------------------------------------------------

M._go = nil
M._parameter = nil
M._rQueue = {}                                        --读队列
M._wQueue = {}                                        --写队列
M._recvBuf = ""                                       --读缓冲区
M._writeBuf = ""                                      --写缓冲区
M._protocol = nil                                      --协议模块
M._sequence = 0
M._timeout = 0
M._heartPackage = ""

function M._start( parameter )
	mSocket, err = socket.connect(parameter.addr, parameter.port)
	if (mSocket) then
		mSocket:settimeout(0)
		M.connect = true
		M._loop(mSocket)
	else
		M._go = nil
		M.connect = false
		coroutine.yield(nil)
	end
	
end

function M._loop(Socket)
	M._heart()
	M._send(Socket)
	local ret = M._recv(Socket)
	--print( ret )
	if (ret == -1) then
		M._rQueue = {}                                       
		M._wQueue = {} 
		M._recvBuf = ""
		M._writeBuf = ""
		M.sequence = 0
		M.connect = false
		M._go = nil
		coroutine.yield(nil)
	else
		coroutine.yield("ok")
		M._loop(Socket)
	end

end

function M._send( Socket)
	local ret = M._wQueueToBuf()
	local _,wait_write,_ = socket.select(nil, {Socket}, 0.05)
	local bufLen = string.len(M._writeBuf)
	if (#wait_write > 0 and bufLen >0 ) then
		--print( "send" )
		local total, err,  partial = mSocket:send(M._writeBuf)
		--print( total,err,partial )
		M._timeout = os.time(  )
		if (not partial) then
			M._writeBuf = ""
		elseif (partial and partial > 0) then
			M._writeBuf = string.sub( M._writeBuf, partial + 1 )
		end
	end
end

function M._recv( Socket)
	local wait_read,_,_ = socket.select({Socket}, nil, 0.05)
	if (#wait_read > 0) then
		local data, err, partial, elapsed = nil, nil, nil, nil
		data, err, partial, elapsed  = Socket:receive('*a')
		if (data) then
			M._recvBuf = M._recvBuf .. data
			M._rBufToQueue()
			return 0
		elseif (err == "closed") then
			 return -1
		elseif (err == "timeout" and partial) then
			M._recvBuf = M._recvBuf .. partial
			M._rBufToQueue()
			return 0
		else
			return 0
		end
	else
		return 0
	end
end

function M._wQueueToBuf(  )
	-- body
	if (#M._wQueue > 0) then
		local t = table.remove( M._wQueue , 1)
		local data = M._protocol.encode(t)
		M._writeBuf = M._writeBuf .. data
		return true
	end
	return false
end

function M._rBufToQueue(  )
	local success, t, total =  M._protocol.decode(M._recvBuf)
	if (success ~= nil) then
		M._rQueue[#M._rQueue+1] = t
		M._recvBuf = string.sub( M._recvBuf, total+1 )
	end
end

function M._heart( )
	local time = os.time(  )
	if ((time - M._timeout) > heartSecond) then
		print( time )
		M._writeBuf = M._writeBuf .. M._heartPackage
	end
	
end


return M