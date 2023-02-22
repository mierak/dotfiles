require("gitsigns").setup({
	signs = {
		add          = { text = "+" },
		change       = { text = "|" },
		delete       = { text = "-" },
		topdelete    = { text = "‾" },
		changedelete = { text = "~" },
		untracked    = { text = "┆" },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    current_line_blame_opts = {
        virt_text         = true,
        virt_text_pos     = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay             = 1000,
        ignore_whitespace = false,
    },
	worktrees = {
		{
			toplevel = vim.env.HOME,
			gitdir = vim.env.HOME .. "/.dots",
		},
	},
    status_formatter = function (status)
        local added, changed, removed, head, root = status.added, status.changed, status.removed, status.head, status.root
        local status_txt = {}
        if added   and added   > 0 then table.insert(status_txt, '+'..added  ) end
        if changed and changed > 0 then table.insert(status_txt, '~'..changed) end
        if removed and removed > 0 then table.insert(status_txt, '-'..removed) end
        if root then table.insert(status_txt, root) end
        if head then table.insert(status_txt, "|  " .. head) end
        return table.concat(status_txt, ' ')
    end
})
