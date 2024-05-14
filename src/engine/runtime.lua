-- Engine runtime. Manages the timestep and the core loop.

local runtime = {
   fps = 0,
   frame = 0,
   dt = 0,
   prev_frame_timestamp = 0,
   uptime = 0,

   --[[
      love.update() will be called with this deltatime.
      Assumed that game updates at 60fps
   --]]
   GAME_TIME_STEP = 1/60,

   --[[
      Maximum frame drops allowed before the game starts to slow down is
      equal to MAX_ACCUM / GAME_TIME_STEP.
   --]]
   MAX_ACCUM = 8/60,

   --[[
      If the game starts going faster than this (120fps), we start slowing it
      down. Main reason for this is to make use of the extra time to hand off
      control to the OS. Love2D in the default love.run() loop just sleeps for 1
      millisecond for that reason, but it's not necessary. We can be nice to the
      OS only when we have the luxury.
   --]]
   THROTTLE_DT = 1/120,

   --[[
      Used for detecting vsync. With vsync on, we don't get exactly 60fps or
      30ps or whatever, there's always some error, so this accounts for it.
   --]]
   FUZZ = 0.0002,
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

      -- Calculate deltatime
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
         local total_time = runtime.THROTTLE_DT - runtime.dt
         local sleep_time = math.floor(total_time)
         local spinlock_time = total_time - sleep_time

         -- NOTE: love.timer.sleep() uses SDL_Delay() behind the scenes, which
         -- can sleep a minimum of 1ms with a precision of 1ms. Meaning, if we
         -- tell it to sleep for 2.4ms, it will likely end up sleeping for 3ms,
         -- which we don't want. So, here we split the time into the integer and
         -- fractional parts. We sleep for the integer number of milliseconds
         -- and spinlock for the fractional.

         if sleep_time > 0 then
            love.timer.sleep(sleep_time)
         end

         local end_time = love.timer.getTime() + spinlock_time
         while spinlock_time > 0 do
            spinlock_time = end_time - love.timer.getTime()
         end
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
