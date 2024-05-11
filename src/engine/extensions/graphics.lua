-- Extra functions for 'love.graphics'

-- The border is on the inside. Like doing 'box-sizing: border-box' in css
function love.graphics.bordered_rectangle(x, y, w, h,
                                          thickness, color, border_color,
                                          border_radius)
   local t = thickness
   local r = border_radius
   -- Draw the border
   love.graphics.setColor(border_color)
   for i=0, thickness, 1 do
      love.graphics.rectangle("line", x+i, y+i, w-i*2, h-i*2, r, r)
   end

   -- Draw the inside rectangle
   local t2 = t * 2
   love.graphics.setColor(color)
   love.graphics.rectangle(
      "fill",
      x + t,  y + t,
      w - t2, h - t2,
      r,      r
   )
end

function love.graphics.progress_bar(
   x, y, w, h,
   fill_amount,
   bar_color,
   background_color,
   border_color,
   bar_radius,
   border_radius,
   border_thickness
)
   local t = border_thickness
   local t2 = border_thickness * 2
   local r = border_radius

   -- Draw the border
   love.graphics.setColor(border_color)
   for i=0, border_thickness, 1 do
      love.graphics.rectangle("line", x+i, y+i, w-i*2, h-i*2, r, r)
   end

   -- Draw the background
   love.graphics.setColor(background_color)
   love.graphics.rectangle(
      "fill",
      x + t,  y + t,
      w - t2, h - t2,
      r,      r
   )

   -- Draw the bar
   local a = clamp(fill_amount, 0, 1)
   if a == 0 then return end
   r = bar_radius
   love.graphics.setColor(bar_color)
   love.graphics.rectangle("fill",
      x + t,        y + t,
      (w - t2) * a, h - t2,
      r,            r
   )
end

function love.graphics.draw_body_no_color(body, fill_type)
   if not body then return end

   for _, f in pairs(body:getFixtures()) do
      local shape = f:getShape()
      if shape:getType() == "edge" then
         love.graphics.line(shape:getPoints())
      elseif shape:getType() == "circle" then
         love.graphics.circle(
            fill_type or (f:isSensor() and "line" or "fill"),
            body:getX(),
            body:getY(),
            shape:getRadius()
         )
      else
         love.graphics.polygon(
            fill_type or "fill",
            body:getWorldPoints(shape:getPoints())
         )
      end
   end
end

function love.graphics.draw_joint(joint, r, color1, color2)
   if not joint then return end

   local x1, y1, x2, y2 = joint:getAnchors()

   if color1 then love.graphics.setColor(color1) end
   love.graphics.circle( "fill", x1, y1, r )

   if color2 then love.graphics.setColor(color2) end
   love.graphics.circle( "fill", x2, y2, r )
end

local debug_colors = {
   ["active"] = {
      border = { 80/255, 110/255, 1, 0.8 },
      inside = { 80/255, 110/255, 1, 0.7 },
   },
   ["inactive"] = {
      border = { 0, 180/255, 0.5, 1 },
      inside = { 0, 180/255, 0.5, 0.7 },
   },
}
function love.graphics.draw_body(body, fill_type)
   if not body then return end

   local colors = debug_colors[body:isActive() and "active" or "inactive"]
   love.graphics.setColor(colors.inside)
   for _, f in pairs(body:getFixtures()) do
      local shape = f:getShape()
      if shape:getType() == "edge" then
         love.graphics.line(shape:getPoints())
      elseif shape:getType() == "circle" then
         love.graphics.circle(
            fill_type or (f:isSensor() and "line" or "fill"),
            body:getX(),
            body:getY(),
            shape:getRadius()
         )
      else
         love.graphics.polygon(
            fill_type or "fill",
            body:getWorldPoints(shape:getPoints())
         )
      end
   end
end
