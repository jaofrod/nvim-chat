package main

import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true }, // retorna true pq isso é só um testículo
}

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan string)

func handleConnections(writer http.ResponseWriter, request *http.Request) {
	conn, err := upgrader.Upgrade(writer, request, nil)
	if err != nil {
		log.Fatal(err)
		return
	}
	defer conn.Close()

	clients[conn] = true
	log.Printf("Cliente conectado: %v\n", conn.RemoteAddr())
	log.Printf("Clientes conectados: %v\n", len(clients))

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			return
		}

		log.Printf("Mensagem recebida: %s\n", p)

		broadcast <- string(p)

		// if err := conn.WriteMessage(messageType, p); err != nil {
		// 	log.Println(err)
		// 	return
		// }
	}
}

func handleMessages() {
	for {
		msg := <-broadcast
		for client := range clients {
			err := client.WriteMessage(websocket.TextMessage, []byte(msg))
			if err != nil {
				log.Printf("Erro ao enviar mensagem: %v", err)
				client.Close()
				delete(clients, client)
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
