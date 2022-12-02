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

return helpers
