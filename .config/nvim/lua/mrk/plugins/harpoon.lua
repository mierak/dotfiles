return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	requires = { { "nvim-lua/plenary.nvim" } },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

        -- stylua: ignore start
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end)
        vim.keymap.set("n", "<leader>hb", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<leader>hq", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<leader>hw", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<leader>hf", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<leader>hp", function() harpoon:list():select(4) end)
		-- stylua: ignore end
	end,
}
