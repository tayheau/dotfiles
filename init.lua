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
	"rust_analyzer"
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

local art = {
	"                 ▀▄          ",
	"                ▄▀           ",
	"              ▄              ",
	"              ▄▀             ",
	"               ▀▄            ",
	"                 ▄           ",
	"                 ▀█          ",
	"                 ▀▄          ",
	"                   ▄         ",
	"             ▄ ▄▄ █          ",
	"             █▀▄  █ ▀█▄█     ",
	"             █  ▀▀██▄ ██     ",
	"                  █ ████     ",
	"             ▀    █ █▄██     ",
	"             █    █ █▄▀█     ",
	"             █▀▄  ▀▄▀▀▄█     ",
	"             █▀▄  ▀▄████     ",
	"          █  █▀▄▀  ▄▀███     ",
	"        ▄█   ██▄▀▄  ▀███     ",
	"        ██▄  ████▄▀  ███     ",
	"        ▀██▀ █████▀▄ ███     ",
	"      ▄▄▄▄▄█ ▄▄▄▄▀█  ███     ",
	"     █ ▀▀█▄▄▄▄▄▀██   ███     ",
	"    ▄█     ▀▄█████▄▄ ████▄   ",
	"▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀" }

local aucomd_group = vim.api.nvim_create_augroup("dotfiles", {
	clear = true
})

local function longest_length(strings)
	local max_len = 0
	for _, s in ipairs(strings) do
		max_len = math.max(max_len, #s)
	end
	return max_len
end

---@param arr_text string[]
local center_art_vert = function(win, arr_text)
	local height = vim.api.nvim_win_get_config(win).height
	for _ = 1, (height - #arr_text) / 2 do
		table.insert(arr_text, 1, "")
	end
	for _ = #arr_text, height do
		table.insert(arr_text, "")
	end
end

local render_art_text = function(win, art_arr, text_arr)
	center_art_vert(win, art_arr)
	center_art_vert(win, text_arr)
	local width = vim.api.nvim_win_get_width(win)
	local cmd_width = longest_length(text_arr)
	return vim.fn.map(art_arr, function(k, v)
		local art_width = vim.fn.strdisplaywidth(v)
		local remaining = width - art_width
		local cmd = text_arr[k + 1] or ""
		if remaining < cmd_width then remaining = cmd_width end
		local left_padding = math.floor((remaining - cmd_width) / 2)
		return v .. string.rep(" ", left_padding) .. cmd
	end)
end

local colorscheme = {
	"#33DF4E",
	"#F92A82",
	"#007CBE",
	"#FF8552",
	"#FFD639",
}

local todo_path = vim.fs.normalize("~/todo_nvim")

local all_tags = {}
local tag_to_color = {}

local hash_str = function(str)
	local h = 0
	for c in str:gmatch(".") do
		h = (h * 31) + string.byte(c) % 2 ^ 31
	end
	return h
end

local get_tag_color = function(tag)
	if not tag_to_color[tag] then
		local color = colorscheme[hash_str(tag) % #colorscheme + 1]
		local hl_name = "tagColor_" .. tag
		vim.api.nvim_set_hl(0, hl_name, { bg = color, fg = "#000000", bold = true })
		tag_to_color[tag] = hl_name
	end
	return tag_to_color[tag]
end

local status_map = {
	["x"] = { name = "done", icon = "●", priority = 3 },
	["-"] = { name = "in_progress", icon = "◎", priority = 1 },
	[" "] = { name = "to_do", icon = "○", priority = 2 },
}

local parse_task = function(line, tag_list)
	line = line:match("^%s*(.-)%s*$")
	local raw_status, rest = line:match("^%[(.)%]%s*(.*)$")
	if not raw_status then return end
	local tags = {}
	rest:gsub("%b[]", function(tag)
		table.insert(tags, tag:sub(2, -2))
		tag_list[tag:sub(2, -2)] = true
	end
	)
	local text = rest:gsub("(%[.+])%s*", "")
	local status = status_map[raw_status]
	return { status = status, tags = tags, text = text }
end

local load_tasks = function(path)
	local tasks = {}
	for task in io.lines(path) do
		table.insert(tasks, task)
	end
	return tasks
end

local ns = vim.api.nvim_create_namespace("todos_dsa")

--
-- local filtering_tags = {
--		["done"] = true,
--		["in_progress"] = true,
--		["done"] = false
-- 	}

local render_todos = function(buf, lines, filtering_status, sorting, ignore_line)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	-- local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_buf_line_count(buf)
	local largest_tag = 0
	local filtered_todos = {}

	for _, u_todo in pairs(lines) do
		local todo = parse_task(u_todo, all_tags)
		if filtering_status[todo.status.name] then
			table.insert(filtered_todos, todo)
			largest_tag = math.max(largest_tag, #table.concat(todo.tags) + 2 * #todo.tags)
		end
	end

	if sorting or sorting == nil then
		table.sort(filtered_todos, function(a, b)
			return a.status.priority < b.status.priority
		end
		)
	end

	-- local num_todo = #filtered_todos
	local start_line = math.max(1, math.floor(height - #filtered_todos - 3))

	for i, l_todo in ipairs(filtered_todos) do
		if i ~= ignore_line then
			-- local state, tags, task = l_todo[1], l_todo[2], l_todo[3]
			local tag_l = 0
			local virt_text = {}
			for _, tag in ipairs(l_todo.tags) do
				table.insert(virt_text, { "[" .. tag .. "]", get_tag_color(tag) })
				tag_l = tag_l + #tag + 2
			end
			-- if #tags > 0 then table.insert(virt_text, { " " }) end
			table.insert(virt_text, { " " })

			table.insert(virt_text, {
				l_todo.status.icon .. " ", "TodoState"
			})
			table.insert(virt_text, { l_todo.text, "TodoTask" })

			vim.api.nvim_buf_set_extmark(buf, ns, start_line - 1, 0, {
				virt_text = virt_text,
				hl_mode = "combine",
				virt_text_pos = "overlay",
				-- virt_text_win_col = 25 + largest_tag - tag_l
			})
		end
		start_line = start_line + 1
	end
end
-- end

-- to print the dashboard
vim.api.nvim_create_autocmd("VimEnter", {
	group = aucomd_group,
	callback = function()
		if vim.fn.argc(-1) > 0 then return end
		local local_width = vim.o.columns
		local local_height = vim.o.lines
		local default_config = {
			relative = "editor",
			width = math.floor(.52 * local_width),
			height = math.floor(.52 * local_height),
			col = (local_width - math.floor(.52 * local_width)) / 2,
			row = (local_height - math.floor(.52 * local_height)) / 2,
			border = "none",
			style = "minimal",
		}
		local buf = vim.api.nvim_create_buf(false, true)
		local win = vim.api.nvim_open_win(buf, false, default_config)
		local todo_list = load_tasks(todo_path)
		local text = render_art_text(win, art, { "Welcome Tayheau" })
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
		local filtering_tags = {
			["done"] = false,
			["in_progress"] = true,
			["to_do"] = true
		}
		render_todos(buf, todo_list, filtering_tags)
		local close_events = {
			"InsertCharPre", "CursorMoved"
		}
		vim.api.nvim_create_autocmd(close_events, {
			group = aucomd_group,
			callback = function()
				vim.schedule(function()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
				end)
			end
		})
	end
})

local filtering_tags = {
	["done"] = true,
	["in_progress"] = true,
	["to_do"] = true
}

local setup_todo_render = function(buf)
	local refresh = function(skip_line)
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		render_todos(buf, lines, filtering_tags, false, skip_line)
	end

	---@param event vim.api.keyset.events
	local autocmd = function(event, callback)
		vim.api.nvim_create_autocmd(event, {
			group = aucomd_group,
			buffer = buf,
			callback = callback
		})
	end

	autocmd("CursorMoved", function()
		local pos = vim.api.nvim_win_get_cursor(0)[1]
		vim.print(vim.fn.line("v"))
		refresh(pos)
	end
	)

	autocmd("WinLeave", function() refresh() end)
end

local todo_list = vim.api.nvim_buf_get_lines(5, 0, -1, false)
setup_todo_render(5)
render_todos(5, todo_list, filtering_tags, false)
