# nvim-chat

Plugin experimental de chat para Neovim usando WebSocket.

O projeto tem duas partes:

- `client/`: plugin Lua para Neovim.
- `server/`: servidor Go que aceita conexões WebSocket e retransmite mensagens para todos os clientes conectados.

## Estado atual

Este repositório ainda é um protótipo. O fluxo previsto é:

1. Subir o servidor local em `localhost:8080`.
2. Abrir o Neovim com o plugin carregado.
3. O plugin conecta no servidor ao iniciar.
4. `ChatSend` envia a linha atual para o chat.
5. `<leader>vc` abre/fecha a janela do chat.
6. `<leader>vs` envia a mensagem.

## Como rodar

Servidor:

```sh
cd nvim-chat/server
go run .
```

Cliente:

Configure o diretório `nvim-chat/client` como plugin no seu gerenciador de plugins do Neovim e chame:

```lua
require("nvim-chat").setup()
```

O cliente depende de um módulo Lua chamado `websocket`, com API compatível com:

```lua
require("websocket")
require("websocket.client").WebsocketClient
```

## Próximos passos sugeridos

- Definir qual biblioteca WebSocket Lua será suportada oficialmente.
- Criar uma estrutura padrão de plugin Neovim, por exemplo `plugin/nvim-chat.lua` para auto-setup opcional.
- Trocar mensagens em texto puro por JSON com `user`, `text` e `timestamp`.
- Adicionar comandos `ChatConnect`, `ChatDisconnect` e configuração de host/porta.
- Adicionar testes para o servidor Go e um smoke test headless para o plugin.
