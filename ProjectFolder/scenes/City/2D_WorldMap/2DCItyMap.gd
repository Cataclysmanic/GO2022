extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()

func spawn_player():
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	var startPos = find_node("PlayerSpawnPoint").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)


func _on_projectile_ready(projectile):

	$Outdoor/Projectiles.add_child(projectile)
