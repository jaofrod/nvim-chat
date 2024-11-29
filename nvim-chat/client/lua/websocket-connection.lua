module("websocket-connection", package.seeall)

local websocket = require("websocket")
websocket.setup()

local websocketClient = require("websocket.client").WebsocketClient

---@class WebsocketClient
local client = nil

W = {}

W.send = function(msg)
	client:try_send_data(msg)
end

W.connect = function(buf)
	client = websocketClient.new({
		connect_addr = "ws://localhost:8080",
		on_message = function(self, msg)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { msg })
		end,
		on_connect = function(self)
			print("Connected")
		end,
		on_disconnect = function(self)
			print("Disconnected")
		end,
		on_error = function(self, err)
			print("Error: ", err)
		end
	})

	client:try_connect()

	print('client', client)

	-- initial test 
	-- vim.defer_fn(function()
	-- 	print("Sending test data")
	-- 	local test_data = "user: 'test', text: 'Hello, world!'"
	-- 	client:try_send_data(test_data)
	-- end, 2000)
end

return W
