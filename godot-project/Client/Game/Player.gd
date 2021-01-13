extends Control

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

export(int) var player : int
export(Vector2) var initial_tile : Vector2

var TileScene = preload("res://Client/Game/Tile.tscn")
var body = []
var current_direction : int = 0
var tween : Tween

var _tile_size : int
var _player : int
var _sprite_idx : int

func _ready():
	add_to_group("players")

func setup(tile_size : int, player : int, sprite_idx : int):
	_tile_size = tile_size
	_sprite_idx = sprite_idx
	_player = player
	
	tween = Tween.new()
	add_child(tween)
	
	var tile = create_body()
	
	var head = body[0]
	head.is_active = true
	head.is_head = true
	head.teleport_to(initial_tile.x, initial_tile.y)

func create_body():
	var tile = TileScene.instance()
	add_child(tile)
	body.append(tile)
	tile.rect_size = Vector2.ONE * _tile_size
	tile.tile_size = _tile_size
	tile.sprite_idx = _sprite_idx
	tile.player = _player
	tile.refresh_texture()
	return tile

func move_to_direction():
	var head : Tile = body[0]
	var movement = DIRECTIONS[current_direction]
	
	var last_tile = Vector2(head.tile_x, head.tile_y)
	head.move_to(head.tile_x + movement.x, head.tile_y + movement.y)
	
	for i in range(1, body.size()):
		var temp = Vector2(body[i].tile_x, body[i].tile_y)
		if (body[i].is_active):
			body[i].move_to(last_tile.x, last_tile.y)
		else:
			body[i].is_active = true
		last_tile = temp

func grow():
	var tile = create_body()
	tile.teleport_to(body[-2].tile_x, body[-2].tile_y)

func tick():
	move_to_direction()

func kill():
	for tile in body:
		tile.queue_free()
	queue_free()
