-- uuid.lua

local _uuid_last = 0

local function uuid()
   _uuid_last = _uuid_last + 1
   return _uuid_last
end

return uuid
