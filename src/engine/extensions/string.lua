-- Functions for the string namespace

function string.join(...)
   local ret = ""
   for _, str in pairs({...}) do
      ret = ret .. str
   end
   return ret
end

function string.trim(str)
  return str:match("^[%s]*(.-)[%s]*$")
end

function string.emacs_delete_last_word(str)
   if string.match(str, "%w$") then
      return string.gsub(str, "[%s]*[%w]+$", "")
   else
      return string.gsub(str, "([%s%p]*)[%w]*[%p%s]*$", "%1")
   end
end

function string.delete_last_char(str)
   return string.sub(str, 1, -2)
end
