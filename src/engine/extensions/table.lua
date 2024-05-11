-- Functions for the table namespace

-- Return next value from the table and cycle if last
function table.cycle(tbl, cur)
   if not tbl then return nil end

   local idx = table.find(tbl, cur)
   if not idx then return tbl[1] end

   if #tbl == idx then
      return tbl[1]
   else
      return tbl[idx+1]
   end
end

function table.assign(into, from)
   if not from then return into end
   if not into then return from end

   for k, v in pairs(from) do
      into[k] = v
   end
   return into
end

function table.reverse(arr)
   local len = #arr
   for i=1, math.floor(len/2) do
      arr[i], arr[len-i+1] = arr[len-i+1], arr[i]
   end
   return arr
end

-- Fills in the holes in an array, but disregards the ordering
function table.quick_squash(arr, len)
   local i = 1
   while true do
      if i >= len then break end
      if arr[i] == nil then
         arr[i] = arr[len]
         arr[len] = nil
         len = len - 1
      end
      i = i + 1
   end

   return arr, len
end

function table.shallow_copy(t, except)
   except = except or {}
   local newt = {}
   for k, v in pairs(t) do
      if not except[k] then
         newt[k] = v
      end
   end
   return newt
end

-- Copies the table deeply, including metatables
function table.deep_copy(t)
   if type(t) ~= "table" then return t end

   local ret = {}
   for k, v in pairs(t) do
      ret[table.deep_copy(k)] = table.deep_copy(v)
   end
   setmetatable(ret, table.deep_copy(getmetatable(t)))
   return ret
end

function table.deep_merge(t1, t2)
   if t1 == nil then t1 = {} end
   if t2 == nil then return t1 end

   for k, v in pairs(t2) do
      if type(v) == "table" and type(t1[k]) == "table" then
         table.deep_merge(t1[k], v)
      else
         t1[k] = v
      end
   end

   return t1
end

function table.find(tbl, val)
   if not tbl then return nil end
   if not val then return nil end

   for k, v in pairs(tbl) do
      if v == val then
         return k
      end
   end

   return nil
end

function table.keys(tbl)
   local keys = {}
   
   for k in pairs(tbl) do
      table.insert(keys, k)
   end

   return keys
end
