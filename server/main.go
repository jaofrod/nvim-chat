package main

import (
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true }, // Aceita qualquer origem enquanto o servidor for local.
}

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan string)
var clientsMu sync.Mutex

func handleConnections(writer http.ResponseWriter, request *http.Request) {
	conn, err := upgrader.Upgrade(writer, request, nil)
	if err != nil {
		log.Printf("Erro ao fazer upgrade da conexão: %v", err)
		return
	}
	defer conn.Close()

	clientsMu.Lock()
	clients[conn] = true
	connectedClients := len(clients)
	clientsMu.Unlock()

	log.Printf("Cliente conectado: %v\n", conn.RemoteAddr())
	log.Printf("Clientes conectados: %v\n", connectedClients)

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			clientsMu.Lock()
			delete(clients, conn)
			clientsMu.Unlock()
			return
		}

		log.Printf("Mensagem recebida: %s\n", p)

		broadcast <- string(p)
	}
}

func handleMessages() {
	for {
		msg := <-broadcast

		clientsMu.Lock()
		connectedClients := make([]*websocket.Conn, 0, len(clients))
		for client := range clients {
			connectedClients = append(connectedClients, client)
		}
		clientsMu.Unlock()

		for _, client := range connectedClients {
			if err := client.WriteMessage(websocket.TextMessage, []byte(msg)); err != nil {
				log.Printf("Erro ao enviar mensagem: %v", err)
				client.Close()
				clientsMu.Lock()
				delete(clients, client)
				clientsMu.Unlock()
			}
		}
	}
}

func main() {
	http.HandleFunc("/", handleConnections)

	log.Println("Servidor rodando na porta 8080")

	go handleMessages()

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}
