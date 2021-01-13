extends Control

export(float) var round_tick
export(int) var map_width
export(int) var map_height

var TileScene = preload("res://Client/Game/Tile.tscn")

var tile_size = 0
var turn_timer = 0

var _is_host : bool
var _relay_client : ClientManager
var _player_number : int
var _player_is_dead : bool
var _players_alive : int

var foods = []
var players = []

signal on_game_over

#func _ready():
#	setup(0, null)
#	randomize()
#
#	spawn_food_tile_at_random()
#	spawn_food_tile_at_random()
#	spawn_food_tile_at_random()
#	spawn_food_tile_at_random()

func setup(player_number : int, relay_client : ClientManager):
	_is_host = player_number == 0
	_relay_client = relay_client
	_player_number = player_number

	tile_size = int(rect_size.y / map_height)
	rect_position.x = (rect_size.x - (tile_size * map_width))/2.0

	players = get_tree().get_nodes_in_group("players")
	var player = players[player_number]
	_players_alive = players.size()

	for i in range(players.size()):
		players[i].setup(tile_size, i, 0 if i == player_number else 1)

	$PlayerInput.player = player
	$PlayerInput.is_host = _is_host
	$PlayerInput.relay_client = relay_client

	for n in range(map_width):
		for m in range(map_height):
			if n == 0 or m == 0 or n == map_width - 1 or m == map_height - 1:
				var tile = TileScene.instance()
				add_child(tile)
				tile.refresh_texture()
				tile.rect_size = Vector2.ONE * tile_size
				tile.tile_size = tile_size
				tile.teleport_to(n, m)

func _set_direction(player_number : int, direction : int):
	if players[player_number] != null:
		players[player_number].current_direction = direction

func _process(delta):
	if (_is_host):
		turn_timer += delta
		if turn_timer > round_tick:
			turn_timer -= round_tick
			tick()

			var message = Message.new()
			message.content = {}
			message.content["host_tick"] = true
			message.content["directions"] = []
			for player in get_tree().get_nodes_in_group("players"):
				message.content["directions"].append(Vector2(player.player, player.current_direction))
			if (_relay_client != null): _relay_client.send_data(message)

func spawn_food_tile_at_random():
	var new_pos = rand_free_pos()
	var tile = TileScene.instance()
	add_child(tile)
	tile.rect_size = Vector2.ONE * tile_size
	tile.tile_size = tile_size
	tile.teleport_to(new_pos.x, new_pos.y)
	tile.is_food = true
	foods.append(tile)
	tile.refresh_texture()

func rand_free_pos():
	var occupied = []

	for player in players:
		for tile in player.body:
			occupied.append(Vector2(tile.tile_x, tile.tile_y))

	for food in foods:
		occupied.append(Vector2(food.tile_x, food.tile_y))

	var rand_pos = Vector2.ZERO
	var tries = 0
	while(true):
		rand_pos = Vector2(2 + randi()%(map_width-4), 2 + randi()%(map_height-4))
		if (!occupied.has(rand_pos)) : break
		else: tries+=1
		if (tries > 50): break

	return rand_pos

func tick():
	check_collisions()
	check_game_over()

	var alive_players = get_tree().get_nodes_in_group("players")
	for player in alive_players:
		player.tick()

func check_game_over():
	if (_players_alive <= 1):
		var message = Message.new()
		message.content = {}
		message.content["gameover"] = true
		_relay_client.send_data(message)

		emit_signal("on_game_over")

func check_collisions():
	var tiles = get_tree().get_nodes_in_group("tiles")
	var tile_positions = {}
	var mark_for_deletion = []

	for tile in tiles:
		tile = tile as Tile
		if (tile.is_disabled): continue

		var pos = Vector2(tile.tile_x, tile.tile_y)
		if not tile_positions.has(pos):
			tile_positions[pos] = tile
		else:
			if (foods.has(tile) or foods.has(tile_positions[pos])):
				if (tile.is_head or tile_positions[pos].is_head):
					var head_tile = tile if tile.is_head else tile_positions[pos]
					var food_tile = tile if tile.is_food else tile_positions[pos]
					players[head_tile.player].grow()
					var free_pos = rand_free_pos()
					food_tile.teleport_to(free_pos.x, free_pos.y)

			else:
				if (tile.is_head): mark_for_deletion.append(tile)
				if (tile_positions[pos].is_head): mark_for_deletion.append(tile_positions[pos])

	var alive_players = get_tree().get_nodes_in_group("players")
	for tile in mark_for_deletion:
		for player in alive_players:
			if player.player == tile.player:
				if (player.player == _player_number):
					_player_is_dead = true
				player.kill()
				_players_alive -= 1
