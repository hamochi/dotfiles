-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = true
lvim.colorscheme = "lunar"
lvim.lsp.diagnostics.virtual_text = true
vim.opt.relativenumber = true
vim.opt.cmdheight = 1
vim.opt.tabstop = 4
vim.opt.expandtab = false
vim.opt.undofile = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.termguicolors = true
-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
vim.cmd("inoremap <C-s> <ESC>:w<CR>")
lvim.keys.normal_mode["<C-a>"] = "ggVG"
lvim.keys.normal_mode["<C-tab>"] = ":BufferLineCycleNext<cr>"
lvim.keys.normal_mode["`"] = ":BufferLineCyclePrev<cr>"
lvim.keys.normal_mode["|"] = ":vsplit<cr>"
lvim.keys.normal_mode["<CR>"] = "o<ESC>"
lvim.keys.normal_mode["<S-CR>"] = "O<ESC>"
lvim.keys.normal_mode["<Del>"] = "diw"
lvim.keys.normal_mode["<C-d>"] = "yy p"

lvim.builtin.which_key.mappings["o"] = { "<cmd>NvimTreeFocus<cr>", "Focus Explorer" }
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<cr>", "Projects" }

lvim.builtin.which_key.mappings.b.n = {
	"<cmd>tabnew<cr>", "New buffer"
}

lvim.builtin.which_key.mappings.b.v = {
	"<cmd>vnew<cr>", "New vertical split buffer"
}

lvim.lsp.buffer_mappings.normal_mode['gp'] = {
	"<cmd>lua require('goto-preview').goto_preview_definition()<cr>", "Preview Definition"
}
lvim.lsp.buffer_mappings.normal_mode['gt'] = {
	"<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>", "Preview Type Definition"
}
lvim.lsp.buffer_mappings.normal_mode['gi'] = {
	"<cmd>lua require('goto-preview').goto_preview_implementation()<cr>", "Preview Implementation"
}
lvim.lsp.buffer_mappings.normal_mode['gP'] = {
	"<cmd>lua require('goto-preview').close_all_win()<cr>", "Close Preview"
}
lvim.lsp.buffer_mappings.normal_mode['gR'] = {
	"<cmd>lua require('goto-preview').goto_preview_references()<cr>", "Preview Reference"
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
	"go"
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

lvim.plugins = {
	{ "folke/tokyonight.nvim" },
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{
		"ggandor/lightspeed.nvim",
		event = "BufRead",
	},
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		config = function()
			require("todo-comments").setup()
		end
	},
	{ "fatih/vim-go" },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		setup = function()
			vim.g.indentLine_enabled = 1
			vim.g.indent_blankline_char = "▏"
			vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard" }
			vim.g.indent_blankline_buftype_exclude = { "terminal" }
			vim.g.indent_blankline_show_trailing_blankline_indent = false
			vim.g.indent_blankline_show_first_indent_level = false
		end
	},
	{ "Mofiqul/dracula.nvim" },
	{ "Mofiqul/vscode.nvim" },
	{ "rafamadriz/neon" },
	{ "khaveesh/vim-fish-syntax" },
	{ "leoluz/nvim-dap-go" },
	{ 'rmagatti/goto-preview',
		config = function()
			require('goto-preview').setup {
				width = 120; -- Width of the floating window
				height = 15; -- Height of the floating window
				border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }; -- Border characters of the floating window
				default_mappings = false; -- Bind default mappings
				debug = false; -- Print debug information
				opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
				resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
				post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
				-- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
				focus_on_open = true; -- Focus the floating window when opening it.
				dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
				force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
				bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
			}
		end
	},
	{ 'anuvyklack/pretty-fold.nvim',
		config = function()
			require('pretty-fold').setup {
				fill_char = ' ',

				remove_fold_markers = true,
			}
		end
	}

}

-- VIM-GO SETTINGS
vim.cmd("let g:go_def_mapping_enabled = 0")
--
-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*" },
	-- enable wrap mode for json files only
	command = "normal zR",
})
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
