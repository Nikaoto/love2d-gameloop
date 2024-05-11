local Camera_Shake = Class:extend({
   duration = 1,
   frequency = 60,
   amplitude = 5,

   sample_count = nil,
   interval_time = nil,

   dx = 0,
   dy = 0,
})

function Camera_Shake:init()
   self.timer = Timer:new()
   self.timer:after(self.duration)

   self.sample_count = 10 * self.duration * self.frequency
   self.interval_time = self.duration / self.sample_count

   -- Generate dx samples
   self.dx_samples = {}
   for i=1, self.sample_count do
      self.dx_samples[i] = lm.random() * self.amplitude * 2 - self.amplitude
   end

   -- Generate dy samples
   self.dy_samples = {}
   for i=1, self.sample_count do
      self.dy_samples[i] = lm.random() * self.amplitude * 2 - self.amplitude
   end
end

function Camera_Shake:lerp_sample_value(samples)
   local i = math.floor(self.timer.time_passed / self.interval_time)
   local ti = i * self.interval_time
   return lerp(
      samples[i] or 0,
      samples[i + 1] or 0,
      (self.timer.time_passed - ti) / self.interval_time
   )
end

function Camera_Shake:update(dt)
   self.timer:update(dt)

   if self.timer.done then
      self.dx = 0
      self.dy = 0
      return
   end

   local decay_mod = 1 - self.timer.time_passed/self.duration
   self.dx = self:lerp_sample_value(self.dx_samples) * decay_mod
   self.dy = self:lerp_sample_value(self.dy_samples) * decay_mod
end

return Camera_Shake
