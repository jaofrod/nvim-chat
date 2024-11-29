local websocket = require("websocket-connection")

local Buf = nil

local function create_window(buf)
	vim.api.nvim_open_win(buf, false, {
		split = "right",
		win = 0,
		width = 50,
	})

	vim.api.nvim_create_user_command("ChatSend", function()
		local msg = vim.api.nvim_get_current_line()
		websocket.send(msg)
		vim.api.nvim_set_current_line("")
	end, {})

	vim.keymap.set("n", "<leader>vs", "<cmd>ChatSend<CR>")
end

local function create_buf()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buf, "*chat*")
	vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })

	Buf = buf
	create_window(buf)

	return buf
end

local function show_chat()
	if Buf == nil then
		create_buf()
	else
		vim.api.nvim_win_close(Buf, true)
	end
end

local function connectToWebsocket()
	print('connectToWebsocket')
	websocket.connect(Buf)
	show_chat()
end

local function setup()
	-- fechar e abrir o chat tbm é uma opção
	vim.api.nvim_set_keymap(
		"n",
		"<leader>vc",
		":lua require('nvim-chat').show_chat()<CR>",
		{ noremap = true, silent = true }
	)

	local augroup = vim.api.nvim_create_augroup("chat", { clear = true })
	-- esse clear serve para limpar o grupo de autocomandos caso ele já exista

	print('setup')
	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		desc = "Connect to websocket on VimEnter event",
		once = true,
		callback = connectToWebsocket,
	})
end

return {
	setup = setup,
}
