-- Input module
-- Simple usage:
--    local conf = { buttons = {...}, axii = {...} }
--    local input = Input:new(conf)
-- Capture inputs each frame from an input_source (joystick/love.keyboard/etc):
--    input:capture_all(input_source)
-- Then input.state will hold all data for that and the previous frame:
--    input.state.buttons["x"].is_down
--    input.state.buttons["x"].was_down
--    input.state.buttons["x"].just_pressed
--    input.state.buttons["x"].just_released
--    input.state.axii["mouse_x"].value
--    input.state.axii["mouse_y"].value
--
-- The conf table looks like this:
-- {
--    capture_fns = {
--       -- Called inside capture_all() for each button
--       -- name is the button name string
--       -- conf is the configuration of the button being captured
--       -- state is the state of the button being captured
--       -- input_module is the entire input module
--       capture_is_button_down = function(name, conf, state, src, input_module)
--          -- We can use src if we wish or call something else
--          return src:isDown(name) or love.keyboard.isDown(name)
--       end,
--
--       -- Called inside capture_all() for each axis
--       capture_axis_value = function(name, conf, state, src, inp)
--          return src:getGamepadAxis(name)
--       end,
--    },
--    buttons = {
--       ["x"] = {
--          -- Overrides function for capturing input on this button only.
--          -- The same arguments are passed, we just don't use them here.
--          capture_is_button_down = function(name)
--             return love.keyboard.isDown(name)
--          end,
--          -- any other data you wish...
--       },
--    },
--    axii = {
--       ["leftx"] = { can be completely empty or include any data you wish }
--       ["mouse_x"] = {
--          capture_axis_value = function()
--             return love.mouse.getX()
--          end,
--          -- Any other config data you wish to have access to inside of the capture fn.
--          -- For example deadzone, threshold, action callback...
--       },
--       ["mouse_y"] = {
--          -- Here we can enforce a vertical deadzone using the arguments provided
--          -- to us to query the previous state and the configured deadzone
--          deadzone = 20,
--          capture_axis_value = function(axis_name, axis_conf, axis_state, src, inp)
--             local value = love.mouse.getY()
--             local diff = math.abs(axis_state.prev_value - value)
--             if diff > axis_conf.deadzone then
--                return value
--             else
--                return 0
--             end
--          end,
--       },
--    }
-- }

local Input = {
   conf = {
      buttons = {},
      axii = {},
   },
   state = {},
   empty_btn_state = {
      just_pressed = false,
      just_released = false,
      is_down = false,
      was_down = false,
   },
   empty_axis_state = {
      value = 0,
   },
}

function Input:new(conf)
   local c = conf or self.conf
   local instance = { conf = c }
   setmetatable(instance, self)
   self.__index = self

   instance:init()
   return instance
end

function Input:init()
   local conf = self.conf
   self.state = {}

   if conf.buttons then
      self.state.buttons = {}
      for btn_name, btn_conf in pairs(conf.buttons) do
         self.state.buttons[btn_name] = {
            is_down = false,
            was_down = false,
            just_released = false,
            just_pressed = false,
         }
      end
   end

   if conf.axii then
      self.state.axii = {}
      for axis_name, axis_conf in pairs(conf.axii) do
         self.state.axii[axis_name] = {
            value = 0,
            prev_value = 0,
         }
      end
   end
end

function Input:capture_all(src)
   if self.conf.buttons then
      for btn_name, btn_conf in pairs(self.conf.buttons) do
         local btn_state = self.state.buttons[btn_name]

         -- Was button down? Remember value of previous frame
         btn_state.was_down = btn_state.is_down

         -- Is button down?
         local capture_fn = btn_conf.capture_is_button_down or
            self.conf.capture_fns.capture_is_button_down
         btn_state.is_down = capture_fn(
            btn_name,
            btn_conf,
            btn_state,
            src,
            self
         )

         -- just_pressed
         if not btn_state.was_down and btn_state.is_down then
            btn_state.just_pressed = true
         else
            btn_state.just_pressed = false
         end

         -- just_released
         if btn_state.was_down and not btn_state.is_down then
            btn_state.just_released = true
         else
            btn_state.just_released = false
         end
      end
   end

   if self.conf.axii then
      for axis_name, axis_conf in pairs(self.conf.axii) do
         local axis_state = self.state.axii[axis_name]

         -- Remember value of previous frame
         axis_state.prev_value = axis_state.value

         -- Capture value
         local capture_fn = axis_conf.capture_axis_value or
            self.conf.capture_fns.capture_axis_value
         axis_state.value = capture_fn(
            axis_name,
            axis_conf,
            axis_state,
            src,
            self
         )
      end
   end

   return self.state
end

return Input
