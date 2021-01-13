extends Node

func _ready():
	randomize()
	var isClient = ProjectSettings.get_setting("Config/IsClient")
	if (isClient):
		get_tree().change_scene("res://Client/Client.tscn")
	else:
		get_tree().change_scene("res://Server/Server.tscn")
