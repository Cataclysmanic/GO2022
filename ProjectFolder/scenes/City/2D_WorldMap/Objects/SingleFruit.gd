extends RigidBody2D

var velocity : Vector2

func _on_Timer_timeout():
	call_deferred("queue_free")

func _ready():
	set_linear_velocity(Vector2.RIGHT.rotated(rand_range(-PI,PI))*rand_range(10.0, 50.0))


	
	
