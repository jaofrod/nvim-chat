local websocket = require("websocket")
websocket.setup()

local websocketClient = require("websocket.client").WebsocketClient

---@class WebsocketClient
local client = nil

local M = {}

M.send = function(msg)
	if client == nil then
		vim.notify("nvim-chat is not connected", vim.log.levels.WARN)
		return
	end

	client:try_send_data(msg)
end

M.connect = function(buf)
	client = websocketClient.new({
		connect_addr = "ws://localhost:8080",
		on_message = function(self, msg)
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, { msg })
				end
			end)
		end,
		on_connect = function(self)
			print("Connected")
		end,
		on_disconnect = function(self)
			print("Disconnected")
		end,
		on_error = function(self, err)
			print("Error: ", err)
		end,
	})

	client:try_connect()
end

return M
