-- Functions for the math namespace

function math.clamp(x, min, max)
   if x < min then return min end
   if x > max then return max end
   return x
end

function math.snap(x, min, max)
   local d1 = math.abs(x - min)
   local d2 = math.abs(x - max)

   if d1 == d2 then
      return x
   elseif d1 < d2 then
      return min
   else
      return max
   end
end

function math.round(x)
  return x >= 0 and math.floor(x + .5) or math.ceil(x - .5)
end

function math.lerp(from, to, amount)
   return from + (to - from) * amount
end

function math.slerp(from, to, amount)
   local smooth_amount = amount * amount * (3 - 2 * amount)
   return from + (to - from) * smooth_amount
end

function math.aabb(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function math.aabb_tbl(r1, r2)
   return
      r1.x < r2.x + r2.w and r2.x < r1.x + r1.w and
      r1.y < r2.y + r2.h and r2.y < r1.y + r1.h
end

function math.aabb_point(px, py, x, y, w, h)
   return px >= x and px <= x + w and
          py >= y and py <= y + h
end

function math.magnitude(x, y)
   return math.sqrt(x * x + y * y)
end
