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

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.world_controller._on_cutscene_finished("Brother") # Replace with function body.


func _on_AnimationPlayer_animation_finished(_anim_name):
	Global.world_controller._on_cutscene_finished("Brother") # Replace with function body.
