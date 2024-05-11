-- Print with tracing
orig_print = print
function printt(...)
  local info = debug.getinfo(2, "Sl")
  local t = { info.short_src .. ":" .. info.currentline .. ":" }
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = string.format("%g", x)
    end
    t[#t + 1] = tostring(x)
  end
  orig_print(table.concat(t, " "))
end

function printf(...)
   local info = debug.getinfo(2, "Sl")
   local str = string.format(...)
   orig_print(info.short_src .. ":" .. info.currentline .. ": " .. str)
end

print = printt
