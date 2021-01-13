extends TextureRect

class_name Tile

export(bool) var is_disabled = false
export(Array, Texture) var player_textures
export(Texture) var wall_texture
export(Texture) var food_texture

var is_head : bool = false
var player : int = -1
var sprite_idx : int = -1
var is_food : bool = false
var is_active : bool = false

var tween : Tween
var tile_x : int
var tile_y : int
var tile_size : int

func _ready():
	add_to_group("tiles")
	tween = Tween.new()
	add_child(tween)

func refresh_texture():
	if (is_food): texture = food_texture
	elif (sprite_idx != -1): texture = player_textures[sprite_idx]
	else: texture = wall_texture

func teleport_to(x, y):
	rect_position = Vector2(x * tile_size, y * tile_size)
	tile_x = x
	tile_y = y

func move_to(x, y):
	tween.interpolate_property(self, ":rect_position", rect_position, Vector2(x * tile_size, y * tile_size), 0.2,Tween.TRANS_CUBIC)
	tile_x = x
	tile_y = y
	tween.start()
