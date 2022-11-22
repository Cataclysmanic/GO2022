extends Node2D

var player

func _ready():
	spawn_player()
	
	Global.current_city_map = self
	
	
func spawn_player():
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	var startPos = find_node("PlayerSpawn").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene
	var camera = playerScene.get_node("Camera2D")
	camera.limit_bottom = 600
	camera.limit_top = 0
	camera.limit_left = -1024
	camera.limit_right = 1024
	camera.zoom = Vector2(1,1)
	

