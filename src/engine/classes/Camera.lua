local Camera = Class:extend({
   x = 0, y = 0,
   w = 0, h = 0,
   zoom = 1,

   lerp_amount = 0.02,
   zoom_speed = 0.01,
   rel_zoom_move_mod = 0.05,
   min_zoom = 0.1,
   max_zoom = 2.5,
   move_speed = 1,
})

local function clamp(x, min, max)
   if x < min then return min end
   if x > max then return max end
   return x
end

local function lerp(from, to, amount)
   return from + (to - from) * amount
end

Camera.interp_fn = lerp

function Camera:init()
   self.shakes = {}
end

function Camera:shake(...)
   table.insert(self.shakes, Camera_Shake:new(...))
end

function Camera:update(dt, target_x, target_y)
   if target_x then
      self.x = self.interp_fn(self.x, target_x, self.lerp_amount)
   end

   if target_y then
      self.y = self.interp_fn(self.y, target_y, self.lerp_amount)
   end

   -- Apply shakes (if any)
   for i=#self.shakes, 1, -1 do
      self.shakes[i]:update(dt)

      self.x = self.x + self.shakes[i].dx
      self.y = self.y + self.shakes[i].dy

      if self.shakes[i].timer.done then
         table.remove(self.shakes, i)
      end
   end
end

function Camera:do_move(dx, dy)
   self.x = self.x + dx * self.move_speed * 1/self.zoom
   self.y = self.y + dy * self.move_speed * 1/self.zoom
end

function Camera:do_zoom(val)
   self.zoom = clamp(
      self.zoom + val * self.zoom_speed,
      self.min_zoom,
      self.max_zoom
   )
end

-- Zoom out from or zoom into the given coordinates
function Camera:do_rel_zoom(val, x, y)
   local prev_zoom = self.zoom
   self:do_zoom(val * prev_zoom)

   -- Don't move if we didn't zoom
   if prev_zoom == self.zoom then return end

   -- Move the camera relative to the coordinates
   local sign = val < 0 and -1 or 1
   self:do_move(
      sign * (x - self.w/2) * self.rel_zoom_move_mod,
      sign * (y - self.h/2) * self.rel_zoom_move_mod
   )
end

function Camera:apply(game_width, game_height)
   lg.translate(
      -self.x * self.zoom + game_width/2,
      -self.y * self.zoom + game_height/2
   )
   lg.scale(self.zoom)
end

function Camera:to_world(x, y, game_width, game_height)
   return self.x + (x - game_width  / 2) / self.zoom,
          self.y + (y - game_height / 2) / self.zoom
end

function Camera:to_screen(x, y, game_width, game_height)
   return (x - self.x) * self.zoom + game_width/2,
          (y - self.y) * self.zoom + game_height/2
end

function Camera:in_view(x, y, w, h)
   if w < 0 then
      x, w = x + w, -w
   end
   if h < 0 then
      y, h = y + h, -h
   end

   if x + w < self.x - self.w/2 then
      return false
   end

   if self.x + self.w/2 < x then
      return false
   end

   if y + h < self.y - self.h/2 then
      return false
   end

   if self.y + self.h/2 < y then
      return false
   end

   return true
end

-- Uses margin
function Camera:in_view_m(m, x, y, w, h)
   if w < 0 then
      x, w = x + w, -w
   end
   if h < 0 then
      y, h = y + h, -h
   end

   if x + w < self.x - self.w/2 - m then
      return false
   end

   if self.x + self.w/2 + m < x then
      return false
   end

   if y + h < self.y - self.h/2 - m then
      return false
   end

   if self.y + self.h/2 + m < y then
      return false
   end

   return true
end

return Camera
