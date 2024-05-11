local Vector = {}

function Vector:new(x, y)
   local instance = {
      x = x or 0,
      y = y or 0
   }
   setmetatable(instance, self)
   self.__index = self

   return instance
end

function Vector:clone()
   return Vector:new(self.x, self.y)
end

function Vector:set(x, y)
   if type(x) == "table" then
      self.x = x.x or self.x
      self.y = x.y or self.y
   else
      self.x, self.y = x, y
   end
   return self
end

function Vector:distance_squared(x, y)
   if type(x) == "table" then
      y = x.y
      x = x.x
   end

   return (self.x - x)^2 + (self.y - y)^2
end

function Vector:distance_from(x, y)
   return math.sqrt(self:distance_squared(x, y))
end

function Vector:magnitude()
   return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:scalar_mult(s)
   self.x = self.x * s
   self.y = self.y * s
   return self
end

function Vector:sub(x, y)
   self.x = self.x - x
   self.y = self.y - y
   return self
end

function Vector:add(x, y)
   self.x = self.x + x
   self.y = self.y + y
   return self
end

function Vector:reverse()
   return self:scalar_mult(-1)
end

function Vector:is_zero()
   return self.x == 0 and self.y == 0
end

function Vector:normalize()
   local len = self:magnitude()
   if len == 0 then
      self.x = 0
      self.y = 0
   else
      self.x = self.x / len
      self.y = self.y / len
   end
   return self
end

function Vector:rotate(rad)
   if rad == 0 then return self end

   local cos = math.cos(rad)
   local sin = math.sin(rad)
   local x = cos * self.x - sin * self.y
   local y = sin * self.x + cos * self.y
   self.x, self.y = x, y

   return self
end

function Vector:get_rotation()
   return math.atan2(self.y, self.x)
end

function Vector:get_horiz_dir()
   if self.x < 0 then
      return -1
   elseif self.x > 0 then
      return 1
   else
      return 0
   end
end

function Vector:get_vert_dir()
   if self.y < 0 then
      return -1
   elseif self.y > 0 then
      return 1
   else
      return 0
   end
end

return Vector
