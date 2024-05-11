local function capture_is_axis_down(name, conf, state, src)
   local value = src:getGamepadAxis(conf.axis_name)
   if math.abs(value) >= conf.threshold then
      return true
   else
      return false
   end
end

local function capture_virt_dir(name, conf, state, src, inp)
   if inp.state.buttons[conf.btn_name].is_down then
      return true
   end

   local val = inp.state.axii[conf.axis_name].value
   if conf.axis_threshold < 0 then
      return val < conf.axis_threshold
   elseif conf.axis_threshold > 0 then
      return val > conf.axis_threshold
   else
      return math.abs(val) > 0
   end
end

local ANALOG_THRESHOLD = 0.22
local TRIGGER_THRESHOLD = 0.8

local default_conf = {
   capture_fns = {
      capture_is_button_down = function(name, conf, state, src)
         return src:isGamepadDown(conf.btn_name or name)
      end,
      capture_axis_value = function(name, conf, state, src)
         return src:getGamepadAxis(conf.axis_name or name)
      end,
      capture_is_axis_down = capture_is_axis_down,
      capture_virt_dir = capture_virt_dir,
   },
   buttons = {
      ["a"] = {},
      ["b"] = {},
      ["x"] = {},
      ["y"] = {},
      ["dpup"] = {},
      ["dpdown"] = {},
      ["dpleft"] = {},
      ["dpright"] = {},
      ["back"] = {},
      ["guide"] = {},
      ["start"] = {},
      ["l1"] = { btn_name = "leftshoulder" },
      ["r1"] = { btn_name = "rightshoulder" },
      ["l2"] = { axis_name = "triggerleft",
                 threshold = TRIGGER_THRESHOLD,
                 capture_is_button_down = capture_is_axis_down },
      ["r2"] = { axis_name = "triggerright",
                 threshold = TRIGGER_THRESHOLD,
                 capture_is_button_down = capture_is_axis_down },
      ["l3"] = { btn_name = "leftstick" },
      ["r3"] = { btn_name = "rightstick" },

      -- These virtual controls allow for merging analog & hat controls.
      -- NOTE: maybe it would be better to use a normalized vector for gamepad
      --       directional controls?
      ["virt_up"] = {
         axis_name = "lefty",
         axis_threshold = -ANALOG_THRESHOLD,
         btn_name = "dpup",
         capture_is_button_down = capture_virt_dir,
      },
      ["virt_down"] = {
         axis_name = "lefty",
         axis_threshold = ANALOG_THRESHOLD,
         btn_name = "dpdown",
         capture_is_button_down = capture_virt_dir,
      },
      ["virt_left"] = {
         axis_name = "leftx",
         axis_threshold = -ANALOG_THRESHOLD,
         btn_name = "dpleft",
         capture_is_button_down = capture_virt_dir,
      },
      ["virt_right"] = {
         axis_name = "leftx",
         axis_threshold = ANALOG_THRESHOLD,
         btn_name = "dpright",
         capture_is_button_down = capture_virt_dir,
      },
   },
   axii = {
      ["leftx"] = {},
      ["lefty"] = {},
      ["rightx"] = {},
      ["righty"] = {},
      ["triggerleft"] = {},
      ["triggerright"] = {},
   }
}

local Joystick_Input = Input:new(default_conf)

return Joystick_Input
