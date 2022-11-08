extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	
func spawn_player():
	var pos = find_node("PlayerSpawnPoint").get_global_position()
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	playerScene.set_global_position(pos)
	add_child(playerScene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_KeyArea_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer.play()
		$Collectibles/KeyArea.queue_free()



func _on_BookArea_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer.play()
		$Collectibles/BookArea.queue_free()
