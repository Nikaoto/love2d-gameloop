local Spritesheet = Class:extend({
   cell_padding = nil, -- set to 0 by default
})

function Spritesheet:new(o)
   assert(o.src)

   return Class.new(self, o)
end

function Spritesheet:init()
   local sheet_w = self.src:getWidth()
   local sheet_h = self.src:getHeight()

   self.cell_padding = self.cell_padding or 0
   self.cell_width = self.cell_width or sheet_w
   self.cell_height = self.cell_height or sheet_h

   local horiz_size = self.cell_padding * 2 + self.cell_width
   self.col_count = math.floor(sheet_w / horiz_size)

   local vert_size = self.cell_padding * 2 + self.cell_height
   self.row_count = math.floor(sheet_h / vert_size)

   self.cells = {}
   for r=1, self.row_count do
      local columns = {}
      local y = self.cell_padding + (r - 1) *  vert_size
      for c=1, self.col_count do
         table.insert(columns, {
            x = self.cell_padding + (c - 1) * horiz_size,
            y = y,
        })
      end
      table.insert(self.cells, columns)
   end
end

function Spritesheet:make_sprite(cell_x, cell_y, q)
   local cell = self.cells[cell_y][cell_x]
   return Sprite:new({
      src = self.src,
      quad = {
         x = cell.x,
         y = cell.y,
         w = (q and q.w) or self.cell_width,
         h = (q and q.h) or self.cell_height,
      },
   })
end

return Spritesheet
