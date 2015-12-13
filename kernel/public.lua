local M = {}
local json = require("json")
local _defaultLocation = system.DocumentsDirectory
-- local _validLocations = {
--    [system.DocumentsDirectory] = true,
--    [system.CachesDirectory] = true,
--    [system.TemporaryDirectory] = true
-- }

function M.init()

end

--圆形是否碰撞
function M.isCircleCollided(obj1, obj2)
    if ( obj1 == nil ) then  --make sure the first object exists
       return false
    end
    if ( obj2 == nil ) then  --make sure the other object exists
       return false
    end
    local pow1 = math.pow(obj1.x-obj2.x, 2)
    local pow2 = math.pow(obj1.y-obj2.y, 2)
    --local pow3 = math.pow(obj1.path.radius+obj2.path.radius, 2)
    local pow3 = obj1.path.radius+obj2.path.radius
    if math.sqrt(pow1+pow2) < pow3 then
        return true
    end
    return false
end

--是否碰撞
function M.collided( obj1, obj2 )
   if ( obj1 == nil ) then  --make sure the first object exists
      return false
   end
   if ( obj2 == nil ) then  --make sure the other object exists
      return false
   end

   local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
   local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
   local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
   local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax

   return (left or right) and (up or down)
end

--已知一个点,角度,距离 求另一个点 返回x,y
function M.PolarPoints(x, y, angle, distance)
    angle = angle * math.pi / 180
    return (x + distance* math.cos(angle)),(y + distance* math.sin(angle))
end


--两点距离
function M.distBetween( obj1, obj2)
   local xFactor = obj2.x - obj1.x
   local yFactor = obj2.y - obj2.y
   local dist = math.sqrt( (xFactor*xFactor) + (yFactor*yFactor) )
   return dist
end

--队列动作
function M.sequenceTo( target, actionList, overCallBack )
   if (#actionList == 0) then
      overCallBack(target)
      return
   end
   local action = table.remove( actionList, 1)
   if (type(action) == "function") then                   --判断动作还是回掉函数
      action(target)
      M.sequenceTo(target, actionList, overCallBack)
   else 
      action.onComplete = function( obj )
         M.sequenceTo(obj, actionList, overCallBack)
      end
      transition.to( target, action )
   end
end

--滑动数字
function M.moveNumber( objText )
  objText.addlist = {} 
  objText.number = 0
  objText.beginNumber = tonumber(objText.text)
  function objText:setNumber( number)
     self.text = tostring( number )
  end 
  function objText:moveTo( number )
    self:setNumber(self.beginNumber + self.number)
    local to = number - tonumber(self.text)
    self:move(to)
  end
  function objText:move( number )
    self:setNumber(self.beginNumber + self.number)
    self.beginNumber = tonumber(self.text)
    self.number = number
    transition.cancel( self )
    self.addlist = {}
    while true do
       local value = math.floor( number / 10)
       if (value > 10 or value < -10) then
          for i=1,9 do
             self.addlist[#self.addlist+1] = value
          end
          number = value
       else
          break
       end
    end
    --M.printTable(self.addlist)
    transition.to( self, {time=40, onComplete = self.onComplete})
  end

  function objText.onComplete( obj )
          --M.printTable(obj.addlist)
         if (#obj.addlist > 0) then
          --print( ">0" )
           local tempNumber = table.remove( objText.addlist, 1)
           obj.text = tostring( tonumber(obj.text) + tempNumber)
           transition.to( obj, {time=40, onComplete = obj.onComplete})
         else
          --print( "<0" )
           obj:setNumber(obj.beginNumber + obj.number)
           obj.number = 0
           obj.beginNumber = tonumber(obj.text)
         end
    end
end

--保存table到文件
function M.saveTable(t, filename, location, crypto)
    location = location or system.DocumentsDirectory
    local path = system.pathForFile( filename, location)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)     --转成json保存文件
        if (crypto == true) then
          local newContents =""
          for i=1, string.len( contents ) do
            local x = string.byte(contents,i) + 4
            newContents = newContents..string.char(x)
          end
          contents = newContents
        end
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

--读取文件到table
function M.loadTable(filename, location, crypto)
    location = location or system.DocumentsDirectory
    local path = system.pathForFile( filename, location)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        local contents = file:read( "*a" )
        if (crypto == true) then
          local newContents = ""
          for i=1, string.len( contents ) do
            local x = string.byte(contents,i) - 4
            newContents = newContents..string.char(x)
          end
          contents = newContents
        end
        myTable = json.decode(contents);      --读取json文件转table
        io.close( file )
        return myTable
    end
    return nil
end

function M.isFileExist( filename, location )
    location = location or system.DocumentsDirectory
    local path = system.pathForFile( filename, location)
    local file = io.open( path, "r" )
    if (file) then
      io.close( file )
      return true
    else
      return false
    end
end

--打印table
function M.printTable ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--指数分布求随机数
function M.random(min, max, average)
    --math.randomseed(os.time());
    local beta = average - min;
    local num  = math.random(1, max-min) / (max-min);
    return min - beta * math.log(num);
end
return M