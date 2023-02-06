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

function helpers.time_to_seconds(time)
    local minutes = tonumber(time:match("(.+):"))
    local seconds = tonumber(time:match(":(.+)"))
    if not minutes or not seconds then return nil end
    return minutes * 60 + seconds
end

function helpers.trim(str)
    return str:match("^%s*(.-)%s*$"):gsub("[ ]+", " "):gsub("\n+", "\n")
end

function helpers.ellipsize(str, max_length)
    if #str > max_length then
        return str:sub(1, max_length - 3) .. "..."
    end
    return str
end

---Pads a string with character from both sides
---@param str string String to pad
---@param char string Character to use for padding
---@param length integer How long should the string be after padding
---@return string
function helpers.pad(str, char, length)
    local pad_size = math.floor((length - #str) / 2)
    local pad_str = string.rep(char, pad_size)
    return pad_str .. str .. pad_str
end

return helpers
