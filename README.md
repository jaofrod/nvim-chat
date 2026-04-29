# nvim-chat

A small experimental chat plugin for Neovim.

This project was started as a prototype and has two parts:

- `nvim-chat/client`: a Neovim plugin written in Lua.
- `nvim-chat/server`: a simple WebSocket broadcast server written in Go.

The idea is to open a chat buffer inside Neovim, connect it to a local WebSocket server, and broadcast messages between connected clients.

## Current Status

This is still an early prototype. It is useful as a starting point, but it is not packaged or polished yet.

The current flow is:

1. Start the Go server on `localhost:8080`.
2. Load the Neovim plugin.
3. The plugin connects to the WebSocket server on startup.
4. Messages typed in the chat buffer can be sent to the server.
5. The server broadcasts messages to all connected clients.

## Running the Server

```sh
cd nvim-chat/server
go run .
```

## Loading the Plugin

Add `nvim-chat/client` to your Neovim runtime path or plugin manager, then call:

```lua
require("nvim-chat").setup()
```

The client currently expects a Lua WebSocket module compatible with:

```lua
require("websocket")
require("websocket.client").WebsocketClient
```

## Keybindings

- `<leader>vc`: open or close the chat window.
- `<leader>vs`: send the current line as a chat message.

## Next Steps

- Pick and document the supported Lua WebSocket dependency.
- Add configuration for host, port, and keybindings.
- Use structured JSON messages instead of plain text.
- Add tests for the Go server.
- Add a minimal Neovim plugin structure for easier installation.
