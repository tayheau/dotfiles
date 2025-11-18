vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.winborder = "rounded"
vim.g.mapleader = " "
vim.opt.termguicolors = true

local function keymap(mode, binding, effect) return vim.keymap.set(mode, binding, effect, { silent = true }) end

keymap('n', '<leader><left>', ':tabp<CR>')
keymap('n', '<leader><right>', ':tabn<CR>')
keymap('n', '<leader>w', ':write<CR>')
keymap('n', '<leader>q', ':quit<CR>')
keymap('n', '<leader>so', ':write<CR> :source<CR>')

vim.pack.add({
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.completion" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/tayheau/nux.nvim" },
})

-- enable the lsp server
vim.lsp.enable({
	"lua_ls",
	"basedpyright",
	"ruff",
	"clangd",
	"ts_ls",
	"bashls",
	"rust_analyzer",
	"tinymist"
})


vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			}
		}
	}
})

vim.diagnostic.config({
	virtual_text = { current_line = true }
})

require "oil".setup()
require "nux".setup()
require "mini.completion".setup()
require "mini.pick".setup()
require "mason".setup()
-- require "dashboard".setup()

keymap('n', '<leader>lf', vim.lsp.buf.format)
keymap('n', '<leader>f', MiniPick.builtin.files)
keymap('n', '<leader>h', MiniPick.builtin.help)
keymap('n', '<leader>b', MiniPick.builtin.buffers)
keymap('n', '<leader>gr', MiniPick.builtin.grep_live)
keymap('n', '<leader>p', Nux.pickWorkspace)
keymap('n', '<leader>-', ':Oil<CR>')
keymap('n', '<leader>vs', ':vsplit<CR> <C-w>l :Pick files<CR>')
keymap('n', '<leader>vt', ':vsplit<CR> <C-w>l :term<CR>')
keymap('t', '<leader>gnt', [[<C-\><C-N>]])
keymap('n', '<leader>t', ':tabnew<CR> :tcd ~<CR>')

vim.cmd("colorscheme vague")
