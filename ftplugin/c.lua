local get_man_description_section = function(word)
	local desc_start, desc_end = nil, nil
	local res, content = pcall(vim.fn.systemlist, "man 3 " .. word .. " | col -b")
	if not res or not content or #content == 0 then return nil end

	for i, line in ipairs(content) do
		if line:match("^DESCRIPTION") then desc_start = i + 1 end
		if desc_start and line:match("^[A-Z][A-Z ]+$") and i > desc_start then
			desc_end = i - 1
			break
		end
	end
	if desc_start and desc_end then
		local desc = table.concat(vim.fn.slice(content, desc_start - 1, desc_end - 1), "\n")
		return desc
	end
end

local enhanced_c_lsp = function()
	local buf = vim.api.nvim_get_current_buf()
	local lsp_hover_win_id = vim.b[buf].lsp_hover_win_id or nil
	if lsp_hover_win_id and vim.api.nvim_win_is_valid(lsp_hover_win_id) then
		vim.api.nvim_set_current_win(lsp_hover_win_id)
	end

	-- if vim.bo.filetype ~= "c" then
	-- 	return vim.lsp.buf.hover()
	-- end
	local cword = vim.fn.expand('<cword>')

	local params = vim.lsp.util.make_position_params(0, 'utf-16')
	local results = vim.lsp.buf_request_sync(0, 'textDocument/hover', params, 500)
	local lsp_contents = nil

	if results then
		for _, res in pairs(results) do
			if res.result and res.result.contents then
				lsp_contents = vim.lsp.util.convert_input_to_markdown_lines(res.result.contents)
				break
			end
		end
	end
	local man_desc = get_man_description_section(cword)

	local lines = {}
	if lsp_contents then
		vim.list_extend(lines, lsp_contents)
	end
	if man_desc then
		table.insert(lines, "")
		table.insert(lines, "---")
		table.insert(lines, "**Manpage Description:**")
		table.insert(lines, "")
		vim.list_extend(lines, vim.split(man_desc, "\n"))
	end

	if #lines > 0 then
		local _, winnr = vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded" })
		vim.b[buf].lsp_hover_win_id = winnr

		vim.api.nvim_create_autocmd("WinClosed", {
			once = true,
			callback = function(args)
				if tonumber(args.file) == winnr then
					vim.b[buf].last_hover_win = nil
				end
			end,
		})

	else
		vim.notify("No documentation found for " .. cword, vim.log.levels.INFO)
	end
end

vim.keymap.set("n", "K", enhanced_c_lsp)
