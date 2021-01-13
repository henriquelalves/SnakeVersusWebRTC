extends Control

var _relay_client : ClientManager
var _game

func _ready():
	_relay_client = $WebsocketClient
	_relay_client.connect("on_message", self, "_on_message")
	_relay_client.connect("on_players_ready", self, "_on_players_ready")
	
	$StartScreen/StartGameButton.connect("pressed", self, "_on_start_game")
	
	$StartScreen.show()
	$Lobby.hide()

func _on_start_game():
	_relay_client.connect_to_server()
	
	$StartScreen.hide()
	$Lobby.show()

func _on_players_ready():
	process_match_start()

func _on_game_over():
	_relay_client.disconnect_from_server()
	
	_game.queue_free()
	$StartScreen.show()

func _on_message(message : Message):
	if (message.server_login): return
	if (message.match_start): return
	else:
		if (message.content.has("seed")):
			process_seed_message(message)
		
		if (message.content.has("directions")):
			process_directions_message(message)
		
		if (message.content.has("gameover")):
			_on_game_over()

func process_match_start():
	# No need to keep connection to matchmaking server
	_relay_client.disconnect_from_server()
	
	_game = load("res://Client/Game/Game.tscn").instance()
	add_child(_game)
	_game.connect("on_game_over", self, "_on_game_over")
	
	$Lobby.hide()
	var peers = _relay_client._match
	_game.setup(peers.find(_relay_client._id), _relay_client)
	
	var is_host = peers.find(_relay_client._id) == 0
	if (is_host):
		var msg = Message.new()
		msg.is_echo = true
		msg.content = {}
		msg.content["seed"] = randi()
		_relay_client.send_data(msg)

func process_directions_message(message : Message):
	for dir in message.content["directions"]:
		_game._set_direction(dir.x, dir.y)
	
	if message.content["host_tick"]:
		_game.tick()

func process_seed_message(message : Message):
	seed(message.content["seed"])
	for i in range(4):
		_game.spawn_food_tile_at_random()
