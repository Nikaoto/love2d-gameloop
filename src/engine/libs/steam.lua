local function load_luasteam()
   return pcall(function() return require("luasteam") end)
end

local status, luasteam

if love.system.getOS() == "OS X" then
   local dir = love.filesystem.getSourceBaseDirectory()
   local old_cpath = package.cpath
   package.cpath = package.cpath .. ";" .. dir .. "/?.so"
   status, luasteam = load_luasteam()
   package.cpath = old_cpath
else
   staus, luasteam = load_luasteam()
end

if status then
   return luasteam
else
   print("Failed to load steam")
   print("steam = ", luasteam)
   return { init = function() return false end }
end
