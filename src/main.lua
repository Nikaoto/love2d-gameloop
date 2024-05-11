require("engine/init")

starting_vsync = 1
always_move_right = true
slowdown_sleep = 0.02
update_slow = false
render_slow = false

ruler_x = 10
ruler_w = 80
player_w = 10
player_x = 10
player_y = 10
player_speed = 10 -- pixels per second

vsync_opts = {0, -1, 1}
GAME_WIDTH = 1024
GAME_HEIGHT = 768
G = {
   objects = {},
   merged_actions = {},
   actions_by_player = {},
   keyboard_input = Keyboard_Input:new(),
   input_mapper = Input_Mapper:new({
      {
         device = "keyboard",
         action_map = {
            ["move_left"] = { input_type = "button", name = "a" },
            ["move_right"] = { input_type = "button", name = "d" },
         },
      }
   }),
}

function love.run()
   return runtime.run()
end

function love.load(args)
   love.window.setMode(GAME_WIDTH, GAME_HEIGHT)
   love.window.setVSync(starting_vsync)

   debug_font = lg.newFont("fonts/fixedsys.ttf", 28)

   canvas = lg.newCanvas(200, 200)
   canvas:setFilter("nearest", "nearest")
end

function love.update(dt)
   if update_slow then
      love.timer.sleep(slowdown_sleep)
   end

   G.keyboard_input:capture_all()
   G.actions_by_player, G.merged_actions = G.input_mapper:map(G.keyboard_input)

   -- Update player
   local act = G.merged_actions
   local dx = 0
   if always_move_right then
      dx = 1
   else
      if act["move_left"].is_down then
         dx = dx - 1
      end
      if act["move_right"].is_down then
         dx = dx + 1
      end
   end

   if dx ~= 0 then
      player_x = player_x + dx * player_speed * dt
   end

   -- Stop simulation after crossing right side of ruler
   if player_x + player_w > ruler_w + ruler_x then
      print(info())
      love.event.quit()
   end
end

function draw_checkerboard(opts)
   local col1 = opts.color1 or {0.8, 0.8, 0.8, 1}
   local col2 = opts.color1 or {0.2, 0.2, 0.2, 1}

   local col = col1
   for x=opts.x, opts.cell_size * opts.cell_count_x, opts.cell_size do
      for y=opts.y, opts.cell_size * opts.cell_count_y, opts.cell_size do
         lg.setColor(col)
         lg.rectangle("fill", x, y, opts.cell_size, opts.cell_size)
         col = col == col1 and col2 or col1
      end
   end
end

function info()
   return fmt(
      "\nplayer_x: %g\n" ..
      "player_speed: %g\n" ..
      "frame: %d\n" ..
      "fps: %g\n" ..
      "uptime: %g\n" ..
      "dropped_frames: %d\n" ..
      "skipped_upates: %d\n" ..
      "vsync: %d\n" ..
      "update_slow: %s\n" ..
      "render_slow: %s",
      player_x,
      player_speed,
      runtime.frame,
      runtime.fps,
      runtime.uptime,
      runtime.dropped_frames,
      runtime.skipped_updates,
      love.window.getVSync(),
      update_slow,
      render_slow
   )
end

function love.draw()
   lg.setCanvas(canvas)
   do
      lg.clear(0.1, 0.1, 0.1, 1)

      draw_checkerboard({
         x = 0, y = 0,
         cell_size = 1,
         cell_count_x = 200,
         cell_count_y = 50,
      })

      -- Ruler
      lg.setColor(0.8, 0.5, 0.2, 1)
      lg.rectangle("fill", ruler_x, 21, ruler_w, 1)

      lg.setColor(1, 0, 0, 1)
      lg.rectangle("fill", player_x, player_y, player_w, player_w)
   end
   lg.setCanvas()

   lg.setColor(1, 1, 1, 1)
   lg.draw(canvas, 0, 0, 0, 8, 8)

   -- Info background
   lg.setColor(0, 0, 0, 0.8)
   lg.rectangle("fill", 0, 440, 400, 328)

   -- Info
   lg.setFont(debug_font)
   lg.setColor(1, 1, 1, 1)
   lg.print(info(), 10, 450)

   if render_slow then
      love.timer.sleep(slowdown_sleep)
   end
end

function love.keypressed(k)
   if k == "v" then
      love.window.setVSync(table.cycle(vsync_opts, love.window.getVSync()))
   end

   if k == "u" then
      update_slow = not update_slow
   end

   if k == "r" then
      render_slow = not render_slow
   end
end
