local websocket = require("websocket-connection")

local ChatBuf = nil
local ChatWin = nil

local function create_window(buf)
	ChatWin = vim.api.nvim_open_win(buf, false, {
		split = "right",
		win = 0,
		width = 50,
	})
end

local function ensure_commands()
	vim.api.nvim_create_user_command("ChatSend", function()
		local msg = vim.api.nvim_get_current_line()
		websocket.send(msg)
		vim.api.nvim_set_current_line("")
	end, { force = true })

	vim.keymap.set("n", "<leader>vs", "<cmd>ChatSend<CR>")
end

local function create_buf()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buf, "*chat*")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("filetype", "nvim-chat", { buf = buf })

	ChatBuf = buf

	return buf
end

local function ensure_buf()
	if ChatBuf == nil or not vim.api.nvim_buf_is_valid(ChatBuf) then
		return create_buf()
	end

	return ChatBuf
end

local function show_chat()
	local buf = ensure_buf()

	if ChatWin ~= nil and vim.api.nvim_win_is_valid(ChatWin) then
		vim.api.nvim_win_close(ChatWin, true)
		ChatWin = nil
		return
	end

	create_window(buf)
end

local function connect_to_websocket()
	local buf = ensure_buf()
	websocket.connect(buf)
	show_chat()
end

local function setup()
	ensure_commands()

	vim.api.nvim_set_keymap(
		"n",
		"<leader>vc",
		":lua require('nvim-chat').show_chat()<CR>",
		{ noremap = true, silent = true }
	)

	local augroup = vim.api.nvim_create_augroup("chat", { clear = true })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		desc = "Connect to websocket on VimEnter event",
		once = true,
		callback = connect_to_websocket,
	})
end

return {
	setup = setup,
	show_chat = show_chat,
}
