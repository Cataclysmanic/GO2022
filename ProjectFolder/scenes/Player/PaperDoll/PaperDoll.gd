extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_running():
	$AnimationPlayer.play("Run")


func start_walking():
	$AnimationPlayer.play("Walk")
	
	
func relax():
	start_idling()
	
func start_idling():
	$AnimationPlayer.play("Relax")
	
func point_gun():
	$AnimationPlayer.play("PointGun")
	
func get_animation():
	var anim_queue = $AnimationPlayer.get_queue()
	if len(anim_queue) > 0:
		return anim_queue[0]

func point_torso_at(targetPos:Vector2):
	$UpperBody.look_at(targetPos)
	
func point_legs_at(targetPos:Vector2):
	$LowerBody.look_at(targetPos)
