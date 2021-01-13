extends Node

var is_host : bool
var relay_client : ClientManager
var player

func _input(event):
	if (player == null): return
	
	if (event is InputEventKey and event.is_pressed()):
		if event.scancode == KEY_UP:
			set_direction(0)
		if event.scancode == KEY_RIGHT:
			set_direction(1)
		if event.scancode == KEY_DOWN:
			set_direction(2)
		if event.scancode == KEY_LEFT:
			set_direction(3)

func set_direction(dir : int):
	if is_host:
		player.current_direction = dir
	else:
		var message = Message.new()
		message.is_echo = false
		message.content = {}
		message.content["host_tick"] = false
		message.content["directions"] = [Vector2(player.player, dir)]
		relay_client.send_data(message)
