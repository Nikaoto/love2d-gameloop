local Sprite = Class:extend({
   src = nil,
   quad = nil,

   origin = "cc", -- bc, tc, cc..

   sx    = 1,   sy    = 1,
   off_x = 0,   off_y = 0,
   ox    = nil, oy    = nil,
   w     = nil, h     = nil,
})

function Sprite:new(o)
   assert(o.src)

   return Class.new(self, o)
end

function Sprite:init()
   local src_w = self.src:getWidth()
   local src_h = self.src:getHeight()

   self.w = self.w or (self.quad and self.quad.w) or src_w
   self.h = self.h or (self.quad and self.quad.h) or src_h

   if self.w == src_w and self.h == src_h then
      self.draw_call = self.draw_img
   else
      self.draw_call = self.draw_quad
      assert(self.quad)
      self._quad = lg.newQuad(
         self.quad.x or 0,
         self.quad.y or 0,
         self.quad.w or self.w,
         self.quad.h or self.h,
         src_w,
         src_h
      )
      if self.quad.wrap then
         self.src:setWrap(self.quad.wrap)
      end
   end

   if self.desired_w then
      self.sx = self.desired_w / self.w
      if not self.desired_h then
         self.sy = self.sx
      end
   end

   if self.desired_h then
      self.sy = self.desired_h / self.h
      if not self.desired_w then
         self.sx = self.sy
      end
   end

   self:align_origin(self.origin)
   self:align_lerp(self.lox, self.loy)

   return self
end

function Sprite:align_origin(o)
   self.origin = o
   if self.origin == "bc" then
      self.ox = self.w/2
      self.oy = self.h
   elseif self.origin == "cc" then
      self.ox = self.w/2
      self.oy = self.h/2
   elseif self.origin == "tc" then
      self.ox = self.w/2
      self.oy = 0
   elseif self.origin == "bl" then
      self.ox = 0
      self.oy = self.h
   elseif self.origin == "br" then
      self.ox = self.w
      self.oy = self.h
   elseif self.origin == "tl" then
      self.ox = 0
      self.oy = 0
   elseif self.origin == "tr" then
      self.ox = self.w
      self.oy = 0
   end
   return self
end

-- Aligns the origin accorting to a fraction [0, 1]
function Sprite:align_lerp(x, y)
   if not x then return self end
   if not y then y = x end

   self.ox = self.w * x
   self.oy = self.h * y
   return self
end

function Sprite:set_origin(ox, oy)
   if ox then self.ox = ox end
   if oy then self.oy = oy end
   return self
end

function Sprite:set_wrap(wrap)
   if self._quad then
      self.src:setWrap(wrap)
   end
   return self
end

function Sprite:offset(x, y)
   self.off_x = x * self.sx
   self.off_y = y * self.sy
   return self
end

-- Sets the internal scale of the sprite
function Sprite:scale(x, y)
   if x and not y then
      y = x
   end

   self.sx = x
   self.sy = y
   return self
end

function Sprite:draw_img(x, y, r, sx, sy, kx, ky)
   lg.draw(
      self.src,
      x, y,
      r,
      sx,      sy,
      self.ox, self.oy,
      kx,      ky
   )
end

function Sprite:draw_quad(x, y, r, sx, sy, kx, ky)
   lg.draw(
      self.src,
      self._quad,
      x, y,
      r,
      sx,      sy,
      self.ox, self.oy,
      kx,      ky
   )
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
   local tsx = self.sx * (sx or 1)
   local tsy = self.sy * (sy or 1)
   kx = kx or 0
   ky = ky or 0

   self:draw_call(
      x + self.off_x * tsx,
      y + self.off_y * tsy,
      r or 0,
      tsx,
      tsy,
      kx,
      ky
   )
end

function Sprite:get_offset(sx, sy)
   local tsx = self.sx * (sx or 1)
   local tsy = self.sy * (sy or 1)
   return x + self.off_x * tsx,
          y + self.off_y * tsy
end

function Sprite:get_rect(x, y, sx, sy)
   local tsx = self.sx * (sx or 1)
   local tsy = self.sy * (sy or 1)

   return
      x - (self.ox * tsx) + (self.off_x * tsx),
      y - (self.oy * tsy) + (self.off_y * tsy),
      self.w * tsx,
      self.h * tsy
end

function Sprite:draw_debug(x, y, r, sx, sy)
   local rect_x, rect_y, rect_w, rect_h =
      self:get_rect(x, y, sx, sy)

   -- NOTE: rotation is not taken into account
   lg.setColor(0.7, 0.2, 0.2, 1)
   lg.rectangle(
      "line",
      rect_x,
      rect_y,
      rect_w,
      rect_h
   )
end

return Sprite
