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

local function nmap(binding, effect) return vim.keymap.set('n', binding, effect, { silent = true }) end
local function keymap(mode, binding, effect) return vim.keymap.set(mode, binding, effect, { silent = true }) end

nmap('<leader><left>', ':tabp<CR>')
nmap('<leader><right>', ':tabn<CR>')
nmap('<leader>w', ':write<CR>')
nmap('<leader>q', ':quit<CR>')
nmap('<leader>so', ':write<CR> :source<CR>')

vim.pack.add({
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
	"lua_ls",
	"basedpyright",
	"ruff",
	"clangd",
	"bashls",
	"tinymist"
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
	style = 'ascii',
})
require "mini.pick".setup()
require "mason".setup()
-- require "dashboard".setup()

nmap('<leader>lf', vim.lsp.buf.format)
nmap('<leader>f', function()
	MiniPick.builtin.files({"rg"})
end)
nmap('<leader>h', MiniPick.builtin.help)
nmap('<leader>b', MiniPick.builtin.buffers)
nmap('<leader>gr', MiniPick.builtin.grep_live)
-- nmap('<leader>p', Nux.pickWorkspace)
nmap('<leader>-', ':Oil<CR>')
nmap('<leader>vs', ':vsplit<CR> <C-w>l :Pick files<CR>')
nmap('<leader>vt', ':vsplit<CR> <C-w>l :term<CR>')
keymap('t', '<leader>gnt', [[<C-\><C-N>]])
nmap('<leader>t', ':tabnew<CR> :tcd ~<CR>')

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
