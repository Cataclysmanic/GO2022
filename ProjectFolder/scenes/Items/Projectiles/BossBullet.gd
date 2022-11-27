extends KinematicBody2D

var velocity = Vector2()
var speed = 500
var damage = 500

var dying = false


func _ready():
	$Sprite2.visible = false


func _physics_process(delta):
	if dying == false:
	
		position += transform.x * speed * delta
		
		
		
		
		velocity = velocity.normalized() * speed
		velocity = move_and_slide(velocity)
		
		
		

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body._on_hit(damage, velocity)
		queue_free()
	else:
		dying = true
		$CollisionShape2D.disabled = true
		$Sprite2.visible = true
		$Sprite.visible = false
		$Sprite2.play("default")



func _on_Sprite2_animation_finished():
	queue_free()
