import websocket

ws = websocket.create_connection("ws://localhost:8000/telescope/ws/12323")
ws.send("Bonjour, ceci est un message textuel")
result = ws.recv()
print(result)
ws.close()
