local all_keys = {
   "return", "escape", "backspace", "tab", "space", "!", "\"", "#", "%", "$",
   "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "[", "\\",
   "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
   "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
   "capslock", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10",
   "f11", "f12", "printscreen", "scrolllock", "pause", "insert", "home",
   "pageup", "delete", "end", "pagedown", "right", "left", "down", "up",
   "numlock", "kp/", "kp*", "kp-", "kp+", "kpenter", "kp0", "kp1", "kp2",
   "kp3", "kp4", "kp5", "kp6", "kp7", "kp8", "kp9", "kp.", "kp,", "kp=",
   "application", "power", "f13", "f14", "f15", "f16", "f17", "f18", "f19",
   "f20", "f21", "f22", "f23", "f24", "execute", "help", "menu", "select",
   "stop", "again", "undo", "cut", "copy", "paste", "find", "mute",
   "volumeup", "volumedown", "alterase", "sysreq", "cancel", "clear",
   "prior", "return2", "separator", "out", "oper", "clearagain",
   "thsousandsseparator", "decimalseparator", "currencyunit",
   "currencysubunit", "lctrl", "lshift", "lalt", "lgui", "rctrl", "rshift",
   "ralt", "rgui", "mode", "audionext", "audioprev", "audiostop",
   "audioplay", "audiomute", "mediaselect", "www", "mail", "calculator",
   "computer", "appsearch", "apphome", "appback", "appforward", "appstop",
   "apprefresh", "appbookmarks", "brightnessdown", "brightnessup",
   "displayswitch", "kbdillumtoggle", "kbdillumdown", "kbdillumup", "eject",
   "sleep"
}

local buttons_table = {}
for _, k in ipairs(all_keys) do
   buttons_table[k] = {}
end

local Keyboard_Input = Input:new({
   capture_fns = {
      capture_is_button_down = function(name)
         return love.keyboard.isDown(name)
      end
   },
   buttons = buttons_table
})

function Keyboard_Input:new()
   return self
end

return Keyboard_Input
