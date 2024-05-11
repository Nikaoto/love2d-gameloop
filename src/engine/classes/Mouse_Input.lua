local Mouse_Input = Input:new({
   capture_fns = {
      capture_is_button_down = function(name, conf)
         return love.mouse.isDown(conf.btn_idx)
      end
   },
   buttons = {
      ["lmb"] = { btn_idx = 1 },
      ["rmb"] = { btn_idx = 2 },
      ["mmb"] = { btn_idx = 3 },
   },
   axii = {
      ["x"] = {
         capture_axis_value = function()
            return love.mouse.getX()
         end
      },
      ["y"] = {
         capture_axis_value = function()
            return love.mouse.getY()
         end
      },
      ["dx"] = {
         capture_axis_value = function(name, conf, state, src, inp)
            local now_x = love.mouse.getX()
            local dx = 0
            if now_x ~= state.prev_x then
               dx = now_x - (state.prev_x or 0)
            end

            state.prev_x = now_x
            return dx
         end,
      },
      ["dy"] = {
         capture_axis_value = function(name, conf, state, src, inp)
            local now_y = love.mouse.getY()
            local dy = 0
            if now_y ~= state.prev_y then
               dy = now_y - (state.prev_y or 0)
            end

            state.prev_y = now_y
            return dy
         end,
      },
      ["wy"] = {
         capture_axis_value = function(_, _, _, _, inp)
            return inp.state.wheelmoved.y
         end
      },
   }
})

function Mouse_Input:new()
   return self
end

Mouse_Input.state.wheelmoved = {
   x = 0,
   y = 0,
}

function Mouse_Input:capture_wheelmoved(x, y)
   self.state.wheelmoved.x = x
   self.state.wheelmoved.y = y
end

function Mouse_Input:capture_all()
   Input.capture_all(self)
   self.state.wheelmoved.x = 0
   self.state.wheelmoved.y = 0
end

return Mouse_Input
