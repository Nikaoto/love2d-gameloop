local eng_dir = (...):match("(.-)[^/]*$")

-- Load extensions (global functions)
require(eng_dir .. "extensions/print")
require(eng_dir .. "extensions/string")
require(eng_dir .. "extensions/table")
require(eng_dir .. "extensions/math")
require(eng_dir .. "extensions/graphics")

-- Aliases/shorthands
fmt = string.format
lg = love.graphics
lm = love.math

-- Load libraries  (self-contained modules)
inspect = require(eng_dir .. "libs/inspect")
dirload = require(eng_dir .. "libs/dirload")
uuid =    require(eng_dir .. "libs/uuid")
lfs =     require(eng_dir .. "libs/lfs_ffi")
--steam = require(eng_dir .. "libs/steam")

-- Load mixins
mixins = dirload("mixins")

-- Load classes
Class =        require(eng_dir .. "classes/Class")
Sprite =       require(eng_dir .. "classes/Sprite")
Spritesheet =  require(eng_dir .. "classes/Spritesheet")
Timer =        require(eng_dir .. "classes/Timer")
Camera_Shake = require(eng_dir .. "classes/Camera_Shake")
Camera =       require(eng_dir .. "classes/Camera")
Deep =         require(eng_dir .. "classes/Deep")
Collider =     require(eng_dir .. "classes/Collider")
Shake =        require(eng_dir .. "classes/Shake")
Vector =       require(eng_dir .. "classes/Vector")

-- Input handling classes
Input =          require(eng_dir .. "classes/Input")
Joystick_Input = require(eng_dir .. "classes/Joystick_Input")
Keyboard_Input = require(eng_dir .. "classes/Keyboard_Input")
Mouse_Input =    require(eng_dir .. "classes/Mouse_Input")
Input_Mapper =   require(eng_dir .. "classes/Input_Mapper")

-- Runtime
runtime = require(eng_dir .. "runtime")
