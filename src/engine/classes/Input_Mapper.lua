-- Maps input state (keyboard, mouse, joysticks) to actions based on mapping
-- config, which can be changed dynamically.
-- The :map() function returns a list of actions arranged by player number.
local Input_Mapper = {}

--[[ conf looks like this:
{
   {
      device = "keyboard",
      action_map = {
         ["move_up"] = { input_type = "button", name = "w" },
         ["move_down"] = { input_type = "button", name = "s" },
         ...
      }
   },
   {
      device = "joystick",
      device_idx = 2,
      action_map = {
         ["move_vert"] = { input_type = "axis", name = "left_analog_y" },
         ["move_horiz"] = { input_type = "axis", name = "left_analog_x" },
         ...
      },
   },
}
--]]

function Input_Mapper:new(conf)
   assert(conf and type(conf) == "table")

   local instance = { conf = conf }
   setmetatable(instance, self)
   self.__index = self

   instance:init()
   return instance
end

function Input_Mapper:init()
   -- Keeping an internal actions table is better than allocating a new one
   -- each time :map() is called
   self.actions = {}
   self.merged_actions = {}

   for player_idx in ipairs(self.conf) do
      self.actions[player_idx] = {}
   end

   return self
end

function Input_Mapper:reconfigure(conf)
   self.conf = conf
   return self:init()
end

function Input_Mapper:map(kb_input, mouse_input, joystick_inputs)
   -- NOTE: If doing this mapping each frame proves to be too slow, the mapping
   --       can be done only once in :init()

   for player_idx, m in ipairs(self.conf) do
      local input_state
      if m.device == "keyboard" then
         input_state = kb_input.state
      elseif m.device == "mouse" then
         input_state = mouse_input.state
      elseif m.device == "joystick" then
         input_state = joystick_inputs[m.device_idx].state
      end

      if not input_state then goto continue end

      for act_name, act_conf in pairs(m.action_map) do
         if act_conf.input_type == "button" then
            local btn_name = act_conf.name or act_name
            if input_state.buttons and input_state.buttons[btn_name] then
               local state = input_state.buttons[btn_name]
               local tfn = act_conf.transform_fn
               if tfn then state = tfn(state) end
               self.actions[player_idx][act_name] = state
            end
         elseif act_conf.input_type == "axis" then
            local axis_name = act_conf.name or act_name
            if input_state.axii and input_state.axii[axis_name] then
               local state = input_state.buttons[axis_name]
               local tfn = act_conf.transform_fn
               if tfn then state = tfn(state) end
               self.actions[player_idx][act_name] = state
            end
         end
      end

      ::continue::
   end

   -- Merge all actions into one table
   -- NOTE: this is slow
   self.merged_actions = table.deep_copy(self.actions[1])
   for i=2, #self.actions do
      for act_name, act_state in pairs(self.actions[i]) do
         for k, v in pairs(act_state) do
            game_state.merged_actions[act_name][k] =
               game_state.merged_actions[act_name][k] or v
         end
      end
   end

   return self.actions, self.merged_actions
end

return Input_Mapper
