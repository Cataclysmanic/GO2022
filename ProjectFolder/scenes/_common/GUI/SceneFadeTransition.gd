# Quick fade transition. Node will free itself after animation plays

extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
