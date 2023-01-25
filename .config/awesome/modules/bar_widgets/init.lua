local current_module = ...

return function (args)
    return require(current_module .. "." .. args.style):new(args)
end
