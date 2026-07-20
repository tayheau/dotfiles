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
	"lua_ls",
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

require "markview".setup({
    preview = {
        icon_provider = "internal", -- "mini" or "devicons"
    }
})
require "oil".setup({
	view_options = { show_hidden = true }
})
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

-- local function show_document_methods()
-- 	local clients = vim.lsp.get_clients({ bufnr = 0 })
-- 	if #clients == 0 then
-- 		vim.notify("No LSP client in this buffer", vim.log.levels.ERROR)
-- 		return
-- 	end
--
-- 	local params = { textDocument = vim.lsp.util.make_text_document_params() }
-- 	vim.lsp.buf_request_all(0, 'textDocument/documentSymbol', params, function(result)
-- 			if not result or vim.tbl_isempty(result) then
-- 				vim.notify("No LSP results", vim.log.levels.WARN)
-- 			return
-- 		end
-- 		for client_id, res in pairs(result) do
-- 	end)
-- end
--
-- keymap("n", "<leader>go", show_document_methods)
--

local function quickfix_symbol()
	local client = vim.lsp.get_clients({ bufnr = 0 })
	if #client == 0 then 
		vim.notify("No LSP client found.", vim.log.levels.ERROR)
		return 
	end
	
	local params = { textDocument = vim.lsp.util.make_text_document_params(0) }
	local KIND = { [5] = true, [12] = true, [6] = true }
	local win = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()

	if vim.bo[bufnr].filetype == "fancysymbol" then
		vim.cmd("close")
		return
	end

	vim.lsp.buf_request_all(bufnr, "textDocument/documentSymbol", params, function(res)
		if not res or vim.tbl_isempty(res) then return end
		_, res = next(res)
		if not res.result or #res.result == 0 then return end
		res = res.result
		win_conifg = {
			relative = "editor",
			row = 1,
			col = 0,
			width = vim.o.columns,
			height = vim.o.lines, 
		}

		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, "__Symbols__")
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = 'wipe'
		local new_win = vim.api.nvim_open_win(buf, true, win_conifg) 
	end)
end

keymap("n", "<leader>go", quickfix_symbol)
