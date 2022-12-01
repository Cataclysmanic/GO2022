extends RigidBody2D

enum States { READY, KICKED }
var State = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY
	set_global_scale(Vector2(1,1))




func _on_Body_entered(body):
	if State == States.READY and body.has_method("is_player") and body.is_player():
		$AnimatedSprite.play("kick")
		State = States.KICKED
		$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
		if has_node("Light2D"):
			$Light2D.energy = 0.0
		
