local state_machine = {}

-- function state_machine.add_state_machine(obj)
--    assert(obj.states)

--    obj.set_state = state_machine.set_state
--    obj.force_set_state = state_machine.force_set_state
--    obj.update_state_machine = state_machine.update_state_machine
-- end

function state_machine.force_set_state(obj, new_state)
   obj.state = nil
   if new_state then
      obj:set_state(new_state)
   end
end

function state_machine.set_state(obj, new_state)
   local old_state = obj.state
   if old_state == new_state then return end

   -- Transition callback
   local can_transition = true
   if old_state and obj.states[old_state].transitions then
      local trans = obj.states[old_state].transitions[new_state]
      if trans then
         can_transition = trans(obj)
      end
   end

   if not can_transition then return end

   obj.state = new_state

   -- Init callback
   local init = obj.states[new_state].init
   if init then init(obj, old_state) end
end

function state_machine.update_state_machine(obj, dt, ...)
   local s = obj.states[obj.state]
   if not s then return end

   if s.update then
      s.update(obj, dt, ...)
   end
end

return state_machine
