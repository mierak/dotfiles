R = function (name)
    require("plenary.reload").reload_module(name)
    return require(name)
end
