local term = {
   width = 320,
   height = 280,
   background_color = {0.1, 0.1, 0.1, 0.8},
   text_color = {1, 1, 1, 1},
   font_path = nil,
   font_size = 16,
   line_height = 20,
   line_draw_cap = 50,
   padding = 5,
   prompt = "> ",
   block_char = "_",
   key_repeat = 0.02,
   scroll_y = 0,
   history_off = 0, -- goes from zero to negative inf
   history_dump_file = "term_history.txt",
}

local lg = love.graphics

function term:new(o)
   local instance = o or {}

   setmetatable(instance, self)
   self.__index = self

   instance:init()
   return instance
end

function term:init()
   self.lines = {
      self.prompt .. self.block_char
   }
   self.prompt_len = string.len(self.prompt)

   self.x = self.x or 0
   self.y = self.y or 0

   self.last_write_time = love.timer.getTime()

   -- Init font
   if self.font_path then
      self.font = lg.newFont(self.font_path, self.font_size, "mono")
   else
      self.font = self.font or lg.newFont(self.font_size, "mono")
   end

   -- Calculate sizes
   local t = lg.newText(self.font, "Mg")
   self.line_height = t:getHeight()
end

function term:cmd_line()
   return self.lines[#self.lines]
end

function term:write_direct(str)
   self.lines[#self.lines] = string.sub(
      self.lines[#self.lines], 1, #self.lines[#self.lines] - 1) ..
         str .. self.block_char

   self.last_write_time = love.timer.getTime()
end

function term:write(str)
   if self.last_write_time + self.key_repeat > love.timer.getTime() then
      return
   end

   self.lines[#self.lines] = string.sub(
      self.lines[#self.lines], 1, #self.lines[#self.lines] - 1) ..
         str .. self.block_char

   self.last_write_time = love.timer.getTime()
end

function term:break_line()
   self:push_line(self.prompt .. self.block_char)
end

function term:backspace()
   if self.last_write_time + self.key_repeat > love.timer.getTime() then
      return
   end

   self.lines[#self.lines] = string.sub(
      self.lines[#self.lines], 1, #self.lines[#self.lines] - 2) ..
         self.block_char

   self.last_write_time = love.timer.getTime()
end

function term:kill_line_backwards()
   if not self.lines[#self.lines] then return end
   self.lines[#self.lines] = self.prompt .. self.block_char
end

function term:kill_word_backwards()
   if not self.lines[#self.lines] then return end
   self.lines[#self.lines] = string.gsub(
      self.lines[#self.lines],
      "(.* ).+",
      "%1"
   ) .. self.block_char
end

function term:set_cmd_content(str)
   if str then
      self.lines[#self.lines] = self.prompt .. str .. self.block_char
   end
end

function term:history_up()
   local nl = #self.lines
   if not self.lines[nl] then return end
   self.history_off = self.history_off - 2
   if nl + self.history_off < 1 then self.history_off = -nl + 1 end

   self.lines[nl] = self.lines[nl + self.history_off] .. self.block_char
end

function term:history_down()
   local nl = #self.lines
   if not self.lines[nl] then return end
   self.history_off = self.history_off + 2
   if self.history_off >= 0 then self.history_off = 0 end

   if self.history_off == 0 then
      self.lines[nl] = self.prompt .. self.block_char
   else
      self.lines[nl] = self.lines[nl + self.history_off] .. self.block_char
   end
end

function term:dump_history()
   local f = love.filesystem.newFile(self.history_dump_file)
   local ok, err = f:open("w")
   if ok then
      for _, l in ipairs(self.lines) do
         f:write(l)
         f:write("\n")
      end
      f:close()
   else
      print("Couldn't open history_dump_file for writing. Error: %s", err)
   end
end

function term:eval_cmd()
   -- Reset history
   self.history_off = 0

   -- Remove block char
   local l = self.lines[#self.lines]
   self.lines[#self.lines] = string.sub(l, 1, string.len(l) - 1)

   -- Extract command without the prompt
   local cmd = string.sub(self.lines[#self.lines], self.prompt_len)

   local fn = loadstring(cmd)
   local suc, err = pcall(fn)
   if not suc then
      self:push_line(err)
   else
      self:push_line(tostring(err))
   end

   self:break_line()
end

function term:push_line(line)
   table.insert(self.lines, line)
end

function term:last_result()
   return self.lines[#self.lines - 1] or ""
end

function term:scroll_vertically(dy)
   self.scroll_y = self.scroll_y + dy
   if self.scroll_y <= -self.height + self.line_height + self.padding then
      self.scroll_y = -self.height + self.line_height + self.padding
   end
end

function term:draw()
   lg.setScissor(self.x, self.y, self.width, self.height)

   -- Background
   lg.setColor(self.background_color)
   lg.rectangle("fill", self.x, self.y, self.width, self.height)

   -- Lines
   if #self.lines > 0 then
      local wrap_limit = self.width - self.padding * 2
      local bottom = self.height - self.padding
      lg.setColor(self.text_color)
      lg.setFont(self.font)
      for i=#self.lines, 1, -1 do
         local _, tbl = self.font:getWrap(self.lines[i], wrap_limit)
         bottom = bottom - #tbl * self.line_height
         lg.printf(
            self.lines[i],
            self.x + self.padding,
            self.y + bottom + self.scroll_y,
            wrap_limit,
            "left"
         )
      end
   end

   lg.setScissor()
end

return term
