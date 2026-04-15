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
	{ src = "https://github.com/melvi-l/housp.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/nvim-mini/mini.completion" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/tayheau/nux.nvim" },
	{ src = "https://github.com/OXY2DEV/markview.nvim" }
})
--
-- enable the lsp server
vim.lsp.enable({
	-- "lua_ls",
	"svelte",
	"basedpyright",
	-- "ruff",
	"clangd",
	"nextflow_ls",
	-- "ts_ls",
	-- "bashls",
	-- "rust_analyzer",
	-- "tinymist"
})

--
-- vim.lsp.config("lua_ls", {
-- 	settings = {
-- 		Lua = {
-- 			workspace = {
-- 				library = vim.api.nvim_get_runtime_file("", true),
-- 			}
-- 		}
-- 	}
-- })
--
-- vim.diagnostic.config({
-- 	virtual_text = { current_line = true }
-- })

require "markview".setup({
    preview = {
        icon_provider = "internal", -- "mini" or "devicons"
    }
})
require "oil".setup()
require "nux".setup()
require "mini.completion".setup()
require "mini.icons".setup({
	style = 'glyph',
})
require "mini.pick".setup()
require "mason".setup()
-- require "dashboard".setup()
local housp = require "housp"
vim.keymap.set({ "n", "v" }, "<leader>cp", housp.copy_permalink({}), { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>op", housp.open_permalink({}), { noremap = true, silent = true })
vim.keymap.set("v", "<leader>sp", housp.copy_snippet({ should_dedent = true, has_langage = true, has_permalink = true }), { noremap = true, silent = true })
vim.keymap.set("n", "<leader>of", function() 
    vim.ui.input({ prompt = "Git URL: " }, housp.setup_permalink({}))
end, { noremap = true, silent = true }) -- args default to system clipboard register

keymap('n', '<leader>lf', vim.lsp.buf.format)
keymap('n', '<leader>f', function()
	MiniPick.builtin.files({"rg"})
end)
keymap('n', '<leader>h', MiniPick.builtin.help)
keymap('n', '<leader>b', MiniPick.builtin.buffers)
keymap('n', '<leader>gr', MiniPick.builtin.grep_live)
-- keymap('n', '<leader>p', Nux.pickWorkspace)
keymap('n', '<leader>-', ':Oil<CR>')
keymap('n', '<leader>vs', ':vsplit<CR> <C-w>l :Pick files<CR>')
keymap('n', '<leader>vt', ':vsplit<CR> <C-w>l :term<CR>')
keymap('t', '<leader>gnt', [[<C-\><C-N>]])
keymap('n', '<leader>t', ':tabnew<CR> :tcd ~<CR>')

vim.cmd("colorscheme vague")

if vim.fn.has("wsl") == 1 then
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("yankwsl", {}),
		desc = "yanking on the system clipboard from a wsl",
		callback = function()
			vim.system({"clip.exe"}, {
				stdin = vim.fn.getreg('"')
			})
		end
	})
end
