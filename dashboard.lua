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
	-- "#ffffff",
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

vim.api.nvim_set_hl(0, "TodoCodeSnippet", { ctermfg = 14, fg = 11448017, italic = true })

local status_map = {
	["x"] = { name = "done", icon = "●", priority = 3 },
	["-"] = { name = "in_progress", icon = "◎", priority = 1 },
	[" "] = { name = "to_do", icon = "○", priority = 2 },
}

local states = {
	["text_snippet"] = { trailing_spaces = 0 },
	["code_snippet"] = { char = "`", highlight = { ctermfg = 14, fg = 11448017, italic = true } }
}

local end_string = function(sm)
	local str = ""
	_, sm.i, str = string.find(sm.input, "([^" .. sm.task_snippets_chars .. "]*)", sm.i)
	str = str:gsub("%s*$", "")
	if str then
		if sm.result.tokens then
			table.insert(sm.result.tokens, { sm.state, str })
		else
			sm.result["tokens"] = { { sm.state, str } }
		end
	end
	sm.i = sm.i + 1
end



local next_non_empty_char = function(sm)
	sm.i = string.find(sm.input, "[^ ]", sm.i + 1)
	-- sm.i = sm.i + 1
end

local close_inline_snippet = function(sm)
	local char = vim.fn.nr2char(sm.byte)
	local str = ""
	_, sm.i, str = sm.input:find(char .. "([^%c].-)" .. char, sm.i)
	if str == nil then error("Error with closing snippets") end
	if sm.result.tokens then
		table.insert(sm.result.tokens, { sm.state, str })
	else
		sm.result["tokens"] = { { sm.state, str } }
	end
	sm.i = sm.i + 1
end

local get_tag = function(sm)
	local tag = nil
	_, sm.i, tag = sm.input:find("%[([a-zA-Z0-9_%-]-)%]", sm.i)
	if not tag then
		error("dev error [tag]")
	end
	sm.i = sm.i + 1
	if sm.result.tags then
		table.insert(sm.result.tags, tag)
	else
		sm.result["tags"] = { tag }
	end
end

local get_status = function(sm)
	local status = {
		[string.byte("x")] = "done",
		[string.byte("-")] = "in_progress",
		[string.byte(" ")] = "to_do"
	}
	local char = nil
	_, sm.i, char = sm.input:find("%[([x%- ])%]", sm.i)
	if not char then
		error('[source "' .. sm.path .. '"] ' .. sm.line .. ": Error with the status syntax (expected [x], [-], or [ ])")
	end
	sm.i = sm.i + 1
	sm.byte = string.byte(char)
	sm.result["status"] = status[sm.byte]
end

local new_line = function(sm)
	sm.line = sm.line + 1
	sm.i = sm.i + 1
	if sm.result ~= {} then table.insert(sm.output, sm.result) end
	sm.result = {}
end


local dev_error = function()
	error("this is a dev error")
end

local BYTE = {
	NEW_LINE = string.byte("\n"),
	LEFT_BRACKET = string.byte("["),
	SPACE = string.byte(" "),
	BACKTICK = string.byte("`"),
	ASTERIX = string.byte("*"),
	UNDERSCORE = string.byte("_"),
}


local updated_transitions = {
	["start_of_line"] = {
		[BYTE.NEW_LINE] = { new_line, "start_of_line" },
		[BYTE.LEFT_BRACKET] = { get_status, "status" },
		[0] = { error, "error" }
	},
	["status"] = {
		[BYTE.LEFT_BRACKET] = { get_tag, "tags" },
		[BYTE.SPACE] = { next_non_empty_char, "text" },
		[0] = { dev_error, "text" }
	},
	["text"] = {
		[BYTE.NEW_LINE] = { new_line, "start_of_line" },
		[BYTE.BACKTICK] = { close_inline_snippet, "code_snippet" },
		[BYTE.ASTERIX] = { close_inline_snippet, "italic_snippet" },
		[0] = { end_string, "text" }
	},
	["code_snippet"] = {
		[BYTE.SPACE] = { next_non_empty_char, "text" },
		[BYTE.NEW_LINE] = { new_line, "start_of_line" },
		[0] = { end_string, "text" }
	},
	["italic_snippet"] = {
		[BYTE.SPACE] = { next_non_empty_char, "text" },
		[BYTE.NEW_LINE] = { new_line, "start_of_line" },
	},
	["bold_snippet"] = {
		[BYTE.UNDERSCORE] = { next_non_empty_char, "text" },
		[BYTE.NEW_LINE] = { new_line, "start_of_line" },
	},
	["tags"] = {
		[BYTE.LEFT_BRACKET] = { get_tag, "tags" },
		[BYTE.SPACE] = { next_non_empty_char, "text" },
		[0] = { end_string, "text" }
	}

}

local transitions = {
	["text"] = { hl = "" },
	["code_snippet"] = { state = "code_snippet", hl = "TodoCodeSnippet", trailing_spaces = 2 },
	[0] = { state = "text" },
	[string.byte("`")] = { state = "code_snippet", hl = "TodoCodeSnippet", trailing_spaces = 2 },
	[string.byte("_")] = { state = "bold_snippet", hl = "PmenuMatch", trailing_spaces = 2 },
}



local parse_task = function(line, tag_list)
	--Finite State Machine Parsing
	local sm = {}
	line = line:match("^%s*(.-)%s*$")
	local raw_status, rest = line:match("^%[(.)%]%s*(.*)$")
	if not raw_status then return end
	local tags = {}
	local text = rest:gsub("%b[]", function(tag)
		table.insert(tags, tag:sub(2, -2))
		tag_list[tag:sub(2, -2)] = true
		return ""
	end
	)
	local last_pos = 1
	text = text:match("^%s*(.-)%s*$")
	local test_tokens = {}
	local tokens = {}
	local code_s = ""
	sm.input = text
	sm.length = #sm.input
	sm.i = 1
	sm.current_transition = nil
	sm.state = "text"
	local state = "text"
	-- while sm.i < sm.length do
	-- 	sm.current = string.byte(sm.input, sm.i)
	-- 	if not updated_transitions[sm.state][sm.current] then
	-- 		sm.current_transition = updated_transitions[sm.state][0]
	-- 		-- code_s = code_s .. text:sub(sm.i, sm.i)
	-- 	else
	-- 		sm.current_transition = updated_transitions[sm.state][sm.current]
	-- 		-- if code_s ~= "" then table.insert(test_tokens, { sm.state, code_s }) end
	-- 		-- sm.state = transition_fct(sm.state, string.byte(sm.string, sm.i))
	-- 		-- code_s = ""
	-- 	end
	-- 	vim.print(sm.i)
	-- 	sm.state = sm.current_transition[2]
	-- 	sm.current_transition[1](sm)
	-- 	-- sm.i = sm.i + 1
	-- end
	-- vim.print(sm.input)
	-- if code_s ~= "" then vim.print({ state, code_s }) end
	if code_s ~= "" then table.insert(test_tokens, { state, code_s }) end
	for pre, code, post in text:gmatch("(.-)`(.-)`()") do
		if pre ~= "" then
			table.insert(tokens, { "text", pre })
		end
		table.insert(tokens, { "code_snippet", code })
		last_pos = post
	end
	if last_pos <= #text then
		table.insert(tokens, { "text", text:sub(last_pos) })
	end
	vim.print(test_tokens)


	local status = status_map[raw_status]
	return { status = status, tags = tags, tokens = tokens }
end


---@param filename string Path of the tdmd file to parse
local parse_tdmd = function(filename, options)
	local sm = {}

	if not options.text_input then
		sm.filename = vim.fs.normalize(filename)
		sm.file = io.open(sm.filename)
		---@type string
		sm.input = sm.file:read("*a")
	else
		sm.input = filename
	end

	sm.i = 1
	sm.result = {}
	sm.output = {}
	sm.cache = {}
	sm.task_snippets_chars = ""
	sm.line = 1
	sm.state = "start_of_line"
	sm.length = #sm.input

	for k, _ in pairs(updated_transitions["text"]) do
		if k ~= 0 then
			table.insert(sm.cache, vim.fn.nr2char(k))
		end
	end
	sm.task_snippets_chars = table.concat(sm.cache)
	sm.cache = {}


	while sm.i <= sm.length do
		sm.byte = sm.input:byte(sm.i)
		sm.transition = updated_transitions[sm.state][sm.byte] or updated_transitions[sm.state][0]
		sm.state = sm.transition[2]
		sm.transition[1](sm)
	end
	if next(sm.result) then table.insert(sm.output, sm.result) end
	sm.result = {}
	return sm.output
end

local load_tasks = function(path)
	local tasks = {}
	for task in io.lines(path) do
		table.insert(tasks, task)
	end
	return tasks
end



---@return vim.api.keyset.set_extmark
local overing_layout = function(buf, todo, i, ignore)
	local mapping_snippet = {
		["text"] = { hl = "" },
		["code_snippet"] = { hl = "TodoCodeSnippet", trailing_spaces = 1 },
		["italic_snippet"] = { hl = "", trailing_spaces = 2 }
	}
	local mapping_status = {
		["done"] = "●",
		["in_progress"] = "◎",
		["to_do"] = "○"
	}

	if ignore then return {} end
	local trailing_spaces = 1
	local virt_text = {}
	table.insert(virt_text, {
		mapping_status[todo.status] .. " ", "TodoState"
	})
	for _, tag in ipairs(todo.tags) do
		table.insert(virt_text, { "[" .. tag .. "]", get_tag_color(tag) })
	end
	table.insert(virt_text, { " " })
	for _, token in pairs(todo.tokens) do
		local k, v = token[1], token[2]
		table.insert(virt_text, { v .. " ", mapping_snippet[k].hl })
		trailing_spaces = trailing_spaces + (mapping_snippet[k].trailing_spaces or 0)
	end

	table.insert(virt_text, { string.rep(" ", trailing_spaces) })
	return {
		virt_text = virt_text,
		hl_mode = "combine",
		virt_text_pos = "overlay"
	}
end

---@return vim.api.keyset.set_extmark
local startup_layout = function(buf, todo, i, ignore)
	local virt_text = {}
	local tag_l = 0
	for _, tag in pairs(todo.tags) do
		table.insert(virt_text, { "[" .. tag .. "]", get_tag_color(tag) })
		tag_l = tag_l + #tag + 2
	end
	table.insert(virt_text, { " " })
	table.insert(virt_text, { todo.status.icon .. " ", "TodoState" })
	table.insert(virt_text, { todo.text .. " ", "TodoTask" })
	return {
		virt_text = virt_text,
		hl_mode = "combine",
		virt_text_pos = "overlay",
		virt_text_win_col = 25 + vim.b[buf].largest_tag - tag_l
	}
end
-- ┣ VR
-- ┗ UR


---@param buf number
---@param sorting? boolean
---@param layout_fn function
local render_todos = function(buf, lines, filtering_status, sorting, skip_lines, layout_fn, ns)
	local render = {}

	render.buf_id = buf
	render.height = vim.api.nvim_buf_line_count(render.buf_id)
	render.lines = vim.deepcopy(lines)
	render.filtered_todos = {}
	render.filtering_status = filtering_status

	vim.api.nvim_buf_clear_namespace(render.buf_id, ns, 0, -1)
	vim.b[render.buf_id].largest_tag = 0


	for _, l in pairs(render.lines) do
		if filtering_status[l.status] then
			table.insert(render.filtered_todos, l)
			-- vim.b[buf].largest_tag = math.max(vim.b[buf].largest_tag, #table.concat(todo.tags) + 2 * #todo.tags)
		end
		-- ::continue::
	end

	-- if sorting or sorting == nil then
	-- 	table.sort(filtered_todos, function(a, b)
	-- 		return a.status.priority < b.status.priority
	-- 	end
	-- 	)
	-- end
	--
	-- local num_todo = #render.filtered_todos
	local start_line = math.max(1, math.floor(render.height - #render.filtered_todos - 3))

	for i, l_todo in ipairs(render.filtered_todos) do
		local ignore_line = not (skip_lines == nil or i < skip_lines[1] or i > skip_lines[2])
		local extmark_opts = vim.fn.call(layout_fn, { buf, l_todo, i, ignore_line })
		vim.api.nvim_buf_set_extmark(buf, ns, start_line - 1, 0, extmark_opts)
		-- end
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
		-- vim.b[buf].largest_tag = compute_max_tag_length(todo_list)
		render_todos(buf, todo_list, filtering_tags, true, nil, startup_layout)
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

---@alias StringSet table< string, boolean >

---@class RenderOptions
---@field text_input? string Default on False. Wether the input string has to be rendered or not.
---@field navigable? boolean Wether the buffer is navigable or not. Default on Fals
---@field filter? StringSet Tag filter table. If not precised every tag will be displayed, otherwise, only enabled tags will be.
---@field ordering? table<string>
---@field layout_fn function


-- setup all autocmds and renderer allocated to a buffer
---@param filename string A valid `buffer_id`, filename or string to render (needs `inline_text` to be set to `true`). A buffer will be created with default `win_config` in the two last cases.
---@param options RenderOptions
---@param win_config? vim.api.keyset.win_config
local tdmd_render = function(filename, win_config, options)
	local render = {}

	if options.text_input then
		render.buf_id = vim.api.nvim_create_buf(false, false)
	else
		render.filename = vim.fs.normalize(filename)
		render.buf_id = vim.fn.bufadd(render.filename)
		vim.fn.bufload(render.buf_id)
	end

	render.height = vim.api.nvim_buf_line_count(render.buf_id)

	local base_win_config = {
		height = render.height,
		split = "above",
		win = 0,
	}

	win_config = vim.tbl_deep_extend('force', base_win_config, win_config or {})

	render.win_id = vim.api.nvim_open_win(render.buf_id, true, win_config or base_win_config)

	render.ns = vim.api.nvim_create_namespace("tdmd_render" .. render.buf_id)
	render.filter = options.filter or {}
	render.lines = parse_tdmd(render.filename, { text_input = options.text_input })
	render.last_tick = 0
	render.pos = {}


	local process_rendering = function()
		local extmark_opts = nil
		local skippable = false
		vim.api.nvim_buf_clear_namespace(render.buf_id, render.ns, 0, -1)
		for i, l in pairs(render.lines) do
			skippable = (next(render.pos) ~= nil and i >= render.pos[1] and i <= render.pos[2])
			if next(l) ~= nil and not skippable then
				extmark_opts = vim.fn.call(options.layout_fn, { render.buf_id, l, i, nil })
				vim.api.nvim_buf_set_extmark(render.buf_id, render.ns, i - 1, 0, extmark_opts)
			end
		end
	end

	local update_lines = function()
		render.lines = parse_tdmd(
			table.concat(vim.api.nvim_buf_get_lines(render.buf_id, 0, -1, false), "\n") .. "\n",
			{ text_input = true }
		)
	end
	-- update_lines()

	local update_render = function(skip_line)
		render_todos(render.buf_id, render.lines, filtering_tags, false, skip_line, options.layout_fn, render.ns)
	end
	process_rendering()

	---@param event vim.api.keyset.events
	local autocmd = function(event, callback)
		vim.api.nvim_create_autocmd(event, {
			group = aucomd_group,
			buffer = render.buf_id,
			callback = callback,
		})
	end

	autocmd("CursorMoved", function()
		render.pos = { vim.fn.line("."), vim.fn.line("v") }
		table.sort(render.pos)
		process_rendering()
	end
	)

	autocmd("ModeChanged", function(args)
		if args.match:match("^[vV\x16]:n") then
			render.pos = { vim.fn.line("."), vim.fn.line("v") }
			process_rendering()
		end
	end)

	autocmd({ "TextChanged", "InsertLeave" }, function()
		if render.last_tick ~= vim.b[render.buf_id].changedtick then
			update_lines()
			render.pos = { vim.fn.line("."), vim.fn.line("v") }
			table.sort(render.pos)
			process_rendering()
			render.last_tick = vim.b[render.buf_id].changedtick
		end
	end
	)

	autocmd("WinLeave", function()
		render.pos = {}
		process_rendering()
	end)
end


tdmd_render("~/todo_nvim", nil, { layout_fn = overing_layout })
