-- Engine runtime. Manages the timestep and the core loop.

local runtime = {
   fps = 0,
   frame = 0,
   dt = 0,
   prev_frame_timestamp = 0,
   uptime = 0,
   prev_second_frame_num = 0,


   throttle_dt = 1/25, -- If dt is below this, we are going too fast

   -- Maximum frame drops allowed before the game starts to slow down is
   -- MAX_ACCUM / GAME_TIME_STEP
   MAX_ACCUM = 8/60,
   GAME_TIME_STEP = 1/30,
   THROTTLE_DT = 1/120,
   FUZZ = 0.0002,
   SDL_MIN_SLEEP = 0.001,
}

function runtime.reset()
   local now = love.timer.getTime()
   runtime.prev_frame_timestamp = now
   runtime.startup = now
   runtime.uptime = 0
   runtime.dt = 0
   runtime.frame = 0
   runtime.fps = 0
   runtime.prev_fps_measure_timestamp = 0
   runtime.accum = 0
   runtime.dropped_frames = 0
   runtime.skipped_updates = 0
end

function runtime.run()
   love.load(love.arg.parseGameArguments(arg), arg)

   runtime.reset()

   return function()
      if love.event then
         love.event.pump()
         for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
               if not love.quit or not love.quit() then
                  return a or 0
               end
            end
            love.handlers[name](a,b,c,d,e,f)
         end
      end

      local now = love.timer.getTime()
      runtime.uptime = now - runtime.startup

      -- Update fps count each second
      if runtime.prev_fps_measure_timestamp + 1 <= now then
         runtime.fps = runtime.frame
         runtime.frame = 0
         runtime.prev_fps_measure_timestamp = now
      end

      runtime.dt = now - runtime.prev_frame_timestamp
      runtime.prev_frame_timestamp = now
      if math.abs(runtime.dt - 1/120) < runtime.FUZZ then
         runtime.dt = 1/120 -- vsync is probably on
      elseif math.abs(runtime.dt - 1/60) < runtime.FUZZ then
         runtime.dt = 1/60 -- vsync is probably on
      elseif math.abs(runtime.dt - 1/30) < runtime.FUZZ then
         runtime.dt = 1/30 -- vsync is probably on
      elseif math.abs(runtime.dt - 1/15) < runtime.FUZZ then
         runtime.dt = 1/15 -- vsync is probably on
      elseif runtime.dt < runtime.THROTTLE_DT then
         -- Going too fast, throttle
         love.timer.sleep(math.max(runtime.THROTTLE_DT - runtime.dt,
                                   runtime.SDL_MIN_SLEEP))
      end

      runtime.accum = math.min(runtime.accum + runtime.dt, runtime.MAX_ACCUM)

      -- Update
      local update_skipped = 1
      local loops = 0
      while runtime.accum >= runtime.GAME_TIME_STEP do
         update_skipped = 0
         loops = loops + 1
         love.update(runtime.GAME_TIME_STEP)
         runtime.accum = runtime.accum - runtime.GAME_TIME_STEP
      end
      runtime.dropped_frames = runtime.dropped_frames +
         (loops > 0 and loops - 1 or 0)
      runtime.skipped_updates = runtime.skipped_updates + update_skipped

      -- Render
      if love.graphics.isActive() then
         love.graphics.origin()
         love.graphics.clear(love.graphics.getBackgroundColor())
         love.draw()
         love.graphics.present()
         runtime.frame = runtime.frame + 1
      end
   end
end

return runtime
