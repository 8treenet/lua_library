local M = {}

function M.init()

end
function M.bytes_to_number(str,endian,signed) -- use length of string to determine 8,16,32,64 bits
    local t={str:byte(1,-1)}
    if endian=="big" then --reverse bytes
        local tt={}
        for k=1,#t do
            tt[#t-k+1]=t[k]
        end
        t=tt
    end
    local n=0
    for k=1,#t do
        n=n+t[k]*2^((k-1)*8)
    end
    if signed then
        n = (n > 2^(#t-1) -1) and (n - 2^#t) or n -- if last bit set, negative.
    end
    return n
end

function M.int_to_bytes(num,endian,n, signed)   --n=1,2,4,8
    if num<0 and not signed then num=-num print"warning, dropping sign from number converting to unsigned" end
    local res={}
    if signed and num < 0 then
        num = num + 2^n
    end
    for k=n,1,-1 do -- 256 = 2^8 bits per char.
        local mul=2^(8*(k-1))
        res[k]=math.floor(num/mul)
        num=num-res[k]*mul
    end
    assert(num==0)
    if endian == "big" then
        local t={}
        for k=1,n do
            t[k]=res[n-k+1]
        end
        res=t
    end
    return string.char(unpack(res))
end


function M.newStream( str )
    -- body
    local stream = {pos=1}
    stream.str = str or ""
    
    function stream:length( )
        return string.len( self.str )
    end

    function stream:readByte(  )
        if (string.len( self.str ) >= self.pos) then
            local byte = string.byte(self.str, self.pos, self.pos)
            self.pos = self.pos+1
            return byte
        else
            return nil
        end

    end
    
    function stream:readInt(  )
        if (string.len( self.str ) >= (self.pos+3)) then
            local numberStr = string.sub( self.str, self.pos, self.pos+3 )
            self.pos = self.pos+4
            return M.bytes_to_number(numberStr ,"big")
        else
            return nil
        end
        
    end

    function stream:readInt64(  )
        if (string.len( self.str ) >= (self.pos+7)) then
            local numberStr = string.sub( self.str, self.pos, self.pos+7 )
            self.pos = self.pos+8
            return M.bytes_to_number(numberStr ,"big")
        else
            return nil
        end
    end

    function stream:readString( len )
        if (string.len( self.str ) >= (self.pos+len-1)) then
            local Str = string.sub( self.str, self.pos, self.pos+len-1 )
            self.pos = self.pos+len
            return Str
        else
            return nil
        end
    end

    function stream:writeByte( byte )
       local numberStr = M.int_to_bytes(byte, "big", 1)
       self.str = self.str..numberStr
    end

    function stream:writeInt( number )
       local numberStr = M.int_to_bytes(number, "big", 4)
       self.str = self.str..numberStr
    end

    function stream:writeInt64( number )
       local numberStr = M.int_to_bytes(number, "big", 8)
       self.str = self.str..numberStr
    end

    function stream:writeString( string )
       self.str = self.str..string
    end

    function stream:getString( )
        return self.str
    end
    return stream
end



return M


