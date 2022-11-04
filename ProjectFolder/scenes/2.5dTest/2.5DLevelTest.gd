extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_KeyArea_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer.play()
		find_node("KeyArea").queue_free()



func _on_BookArea_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer.play()
		find_node("BookArea").queue_free()
