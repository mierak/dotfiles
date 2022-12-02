local helpers = {}

local function tchelper(first, rest)
   return first:upper()..rest:lower()
end

function helpers.title_case(str)
    return str:gsub("(%a)([%w_']*)", tchelper)
end

function helpers.nil_or_empty(str)
    return str == nil or str:match("%S") == nil
end

return helpers
