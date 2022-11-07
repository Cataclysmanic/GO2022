extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_walking():
	$AnimationPlayer.play("Walk")

func start_running():
	$AnimationPlayer.play("Run")
	
func point_gun():
	$AnimationPlayer.play("Point Gun")
	
func start_idling():
	$AnimationPlayer.play("Idle")
	
func relax():
	start_idling()
	
func point_torso_at(targetPos: Vector3):
	
	$UpperBody.look_at(Vector3.ZERO, to_local(targetPos))
	
func point_legs_at(movement_vector: Vector3):
	$LowerBody.look_at(Vector3.ZERO, movement_vector)
	

	
	
