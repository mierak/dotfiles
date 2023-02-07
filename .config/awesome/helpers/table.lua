local helpers = {}

function helpers.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function helpers.contains_key(table, key)
    for k, _ in pairs(table) do
        if k == key then
            return true
        end
    end
    return false
end

function helpers.to_string(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. helpers.table.to_string(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

---Shallow compares two arrays for equality
---@param table1 any[]
---@param table2 any[]
---@return boolean true if arrays are equal, false otherwise
function helpers.array_equals(table1, table2)
    if table1 == nil or table2 == nil then return false end
    if #table1 ~= #table2 then return false end

    for index, val in ipairs(table1) do
        if val ~= table2[index] then
            return false
        end
    end
    return true
end

return helpers
