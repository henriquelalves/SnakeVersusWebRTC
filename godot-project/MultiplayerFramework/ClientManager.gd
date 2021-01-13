extends Node

class_name ClientManager

export(String) var websocket_url = "godot-server.captain.perons.com.br"
export(int) var port = 9080

var _rtc : RTC_Client
var _match = []
var _rtc_peers = {}
var _id = 0
var _player_number = 0
var _client : WebSocketClient
var _initialised = false
var players_ready : bool = false

var uri : String

signal on_message(message)
signal on_players_ready()

func send_data(message : Message):
	if (players_ready):
		_rtc.rtc_mp.put_packet(message.get_raw())
		if message.is_echo:
			emit_signal("on_message", message)
	else:
		_client.get_peer(1).put_packet(message.get_raw())

func connect_to_server():
	uri = "ws://" + websocket_url + ":" + str(port)
	
	players_ready = false
	_rtc = load("res://WebsocketRelay/WebRTCClient.tscn").instance()
	_match = []
	_rtc_peers = {}
	_id = 0
	_player_number = 0
	_client = WebSocketClient.new()
	_initialised = false

	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	
	add_child(_rtc)
	_rtc.connect("on_message", self, "rtc_on_message")
	_rtc.connect("on_send_message", self, "rtc_on_send_message")
	_rtc.connect("peer_connected", self, "rtc_on_peer_connected")

	var err = _client.connect_to_url(uri)
	if err != OK:
		set_process(false)

func rtc_on_peer_connected(id):
	_rtc_peers[id] = true
	
	for peer in _rtc_peers.keys():
		if not _rtc_peers[peer]:
			return
	players_ready = true
	emit_signal("on_players_ready")

func rtc_on_message(message : Message):
	emit_signal("on_message", message)

func rtc_on_send_message(message : Message):
	send_data(message)

func disconnect_from_server():
	_client.disconnect_from_host()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected to server!")

func _on_data():
	var data = _client.get_peer(1).get_packet()
	
	var message = Message.new()
	message.from_raw(data)
	
	if (message.server_login):
		_id = message.content
		_initialised = true
		print("Logged in with id ", _id)
	if (message.match_start):
		_match = message.content as Array
		_player_number = _match.find(_id)
		print("Match started as player ", _player_number)
		
		_rtc.initialize(_id)
		for player_id in _match:
			if (player_id != _id):
				_rtc_peers[player_id] = false
				_rtc.create_peer(player_id)
	else:
		print("On message: ", message.content)
		_rtc.on_received_setup_message(message)
	
	emit_signal("on_message", message)

func _process(delta):
	if (_client != null): _client.poll()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if (_client != null): _client.disconnect_from_host()
