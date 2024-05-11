local Timer = {
   callback = nil,
   seconds = nil,
   mode = nil,
   seconds_table = nil, -- Used for random delays
}

local ONESHOT_MODE = 1
local INTERVAL_MODE = 2

local function random_choice(t)
   return t[math.random(#t)]
end

function Timer:new(o)
   local instance = o or {}

   setmetatable(instance, self)
   self.__index = self

   instance:reset()
   return instance
end

function Timer:reset()
   self.done = false
   self.time_passed = 0
   if self.seconds_table then
      self.seconds = random_choice(self.seconds_table)
   end
end

function Timer:after(sec, cb)
   self.mode = ONESHOT_MODE
   self.callback = cb

   if type(sec) == "number" then
      self.seconds = sec
   else
      self.seconds_table = sec
      self.seconds = random_choice(self.seconds_table)
   end

   self:reset()
   return self
end

function Timer:every(sec, cb)
   self.mode = INTERVAL_MODE
   self.callback = cb
   if type(sec) == "number" then
      self.seconds = sec
   else
      self.seconds_table = sec
      self.seconds = random_choice(self.seconds_table)
   end
   self:reset()
   return self
end

function Timer:update(dt, ...)
   if not self.mode then return end
   if self.done then return end

   self.time_passed = self.time_passed + dt
   if self.time_passed >= self.seconds then
      self.time_passed = self.time_passed - self.seconds

      if self.seconds_table then
         self.seconds = random_choice(self.seconds_table)
      end

      if self.mode == ONESHOT_MODE then
         self.done = true
      end

      if self.callback then self.callback(...) end
   end
end

function Timer:get_remaining_time()
   if self.done then return 0 end
   return self.seconds - self.time_passed
end

return Timer
