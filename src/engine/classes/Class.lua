local Class = {}

function Class:extend(o)
   local subclass = o or {}
   subclass.super = self
   setmetatable(subclass, self)
   self.__index = self
   return subclass
end

function Class:new(o)
   local instance = o or {}
   -- NOTE: instance.super skipped
   setmetatable(instance, self)
   self.__index = self

   instance:init()
   return instance
end

function Class:init()
end

return Class
