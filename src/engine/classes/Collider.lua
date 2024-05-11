local Collider = Class:extend({
   -- events
   EV_ENTER = 1,
   EV_EXIT = 2,
   EV_NO_CHANGE = 3,

   print_debug_info = false,
   debug_colors = {
      ["active"] = {
         border = { 80/255, 110/255, 1, 0.8 },
         inside = { 80/255, 110/255, 1, 0.1 },
      },
      ["inactive"] = {
         border = { 0, 180/255, 0.5, 0.8 },
         inside = { 0, 180/255, 0.5, 0.1},
      },
   },

   x = 0,    y = 0,
   w = 0,    h = 0,
   sx = 1,   sy = 1,
   ox = 0,   oy = 0, -- offset of top-left coord from center

   -- Internal coords used for calculating x & y with scale
   ix = 0, iy = 0,
   iw = 0, ih = 0,

   active = true,
   parent = nil,
})

function Collider:new(o)
   assert(o and type(o) == "table")
   assert(o.x ~= nil and o.y ~= nil)
   assert(o.w ~= nil and o.h ~= nil)

   return Class.new(self, o)
end

function Collider:init()
   Class.init(self)

   self.collisions = {}

   -- Set internal values
   self.ix = self.x
   self.iy = self.y
   self.iw = self.w
   self.ih = self.h
end

function Collider:aabb(x1, y1, w1, h1)
   return x1 < self.x + self.w and self.x < x1 + w1 and
          y1 < self.y + self.h and self.y < y1 + h1
end

local function aabb_tbl(r1, r2)
   return
      r1.x < r2.x + r2.w and r2.x < r1.x + r1.w and
      r1.y < r2.y + r2.h and r2.y < r1.y + r1.h
end

function Collider:recalc()
   self.w = self.iw * self.sx
   self.h = self.ih * self.sy

   self.x = self.ix - (self.iw/2 + self.ox) * self.sx
   self.y = self.iy - (self.ih/2 + self.oy) * self.sy
end

function Collider:set_position(x, y)
   self.ix = x
   self.iy = y
   self:recalc()
end

function Collider:move(dx, dy)
   self.ix = self.ix + dx
   self.iy = self.iy + dy
   self:recalc()
end

function Collider:set_scale(sx, sy)
   self.sx = sx
   self.sy = sy
   self:recalc()
end

function Collider:check_collision(other_bb)
   local is_colliding = self.active and other_bb.active and aabb_tbl(self, other_bb)
   local was_colliding = self.collisions[other_bb] ~= nil

   if not was_colliding and is_colliding then
      self.collisions[other_bb] = other_bb
      return Collider.EV_ENTER
   end

   if not is_colliding and was_colliding then
      self.collisions[other_bb] = nil
      return Collider.EV_EXIT
   end

   return Collider.EV_NO_CHANGE
end

function Collider:get_cc_point()
   return self.x + self.w/2, self.y + self.h/2
end

function Collider:get_cl_point()
   return self.x, self.y + self.h/2
end

function Collider:get_tl_point()
   return self.x, self.y
end

function Collider:get_tc_point()
   return self.x + self.w/2, self.y
end

function Collider:get_bc_point()
   return self.x + self.w/2, self.y + self.h
end

function Collider:get_br_point()
   return self.x + self.w, self.y + self.h
end

function Collider:get_center_point()
   return self.x + self.w/2, self.y + self.h/2
end

function Collider:draw()
   if PRINT_DEBUG_INFO or self.print_debug_info then
      local colors = self.debug_colors[self.active and "active" or "inactive"]
      lg.bordered_rectangle(
         self.x,
         self.y,
         self.w,
         self.h,
         1,
         colors.inside,
         colors.border,
         0
      )
      lg.setColor(1, 1, 1, 1)
      lg.circle("fill", self.x, self.y, 5)
      lg.setFont(fonts.debug)
      lg.print(fmt("\n%g, %g", self.x, self.y), self.x, self.y)
   end
end

return Collider
