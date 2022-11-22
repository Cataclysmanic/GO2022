extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("alerted")
	$Timer.start()


func die():
	call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_global_rotation(0.0)


func _on_Timer_timeout():
	die()
