local M = {}

function M.init()

end

local width = display.contentWidth
local height = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

--面板group
function M.newPanel( background )
	if (background == nil) then
		return nil
	end
	local group = display.newGroup( )
	group.anchorChildren = true
	function group:addObject( obj, nX, nY )
		obj.anchorX = 0
		obj.anchorY = 0
		nX = nX or 0
		nY = nY or 0
		obj.x = nX
		obj.y = nY
		self:insert( obj)
	end
	function group:addSprite( obj, nX, nY )
		nX = nX or 0
		nY = nY or 0
		obj.x = nX
		obj.y = nY
		self:insert( obj)
	end
	background.x = 0
	background.y = 0
	group:addObject(background)
	return group
end

--跟随精灵group
function M.newFollow(nWidth, nHeight)
	local group = display.newGroup( )
	group.bStop = false                      --是否暂停
	group.nFollowWidth = nWidth
	group.nFollowHeight = nHeight
	--暂停
	function group:stop(  )
		self.bStop = true
		local num = self.numChildren
		for i=1, num do
			if (self[num].stop ~= nil) then
				self[num].stop()
				return true 
			end
		end
		return false
	end

    --开启跟随精灵  跟随的精灵，在屏幕中的位置
	function group:startFollow( objPlayer)
		local num = self.numChildren
		for i=1, num do
			if (self[num] == objPlayer) then
				self.objFollowPlayer = objPlayer
				return true 
			end
		end
		return false
	end
	function group:stopFollow( )
		self.objFollowPlayer = nil
	end

	--遍历子控件frame
	function group:_childFrame( event )
		local num = self.numChildren
		for i=1, num do
			if (self[num].frame ~= nil) then
				self[num].frame(event)
				return true 
			end
		end	
	end
		--每帧调用
	function group:frame( event )
		if (self.bStop) then
			return
		end
		self:_childFrame(event)
		if self.objFollowPlayer ~= nil then
			self:_follow()
		end
	end
	--处理跟随
	function group:_follow(  )
		nX, nY = self.objFollowPlayer.x, self.objFollowPlayer.y
		if (nX > centerX and nX < (self.nFollowWidth - centerX)) then
			self.x = -(self.objFollowPlayer.x - centerX)
		end
		if (nY > centerY and nY < (self.nFollowHeight - centerY) ) then
			self.y = -(self.objFollowPlayer.y - centerY)
		end
	end
	return group
end

return M