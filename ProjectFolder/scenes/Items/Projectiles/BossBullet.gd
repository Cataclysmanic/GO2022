extends KinematicBody2D

var velocity = Vector2()
var speed = 500
var damage = 500

func _ready():
	pass


func _physics_process(delta):
	
	position += transform.x * speed * delta
	
	
	
	
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	
	
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body._on_hit(damage, velocity)
		queue_free()
	else:
		queue_free()

