extends Node2D

export var bullet_speed : float
var velocity : Vector2
var damage = 30.0
var originator
var snakeify = false 

signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(originator)
	pass

func init(source, pos : Vector2, rot : float, speed : float):
	originator = source
	set_global_position(pos)
	set_global_rotation(rot)
	if speed != null:
		bullet_speed = speed
	velocity = (bullet_speed * Vector2.RIGHT.rotated(rot))


func _process(delta):
	if !(snakeify and !"Gun2D" in str(originator)):
		set_global_position(get_global_position() + velocity * delta)
	else:
		pass
	if snakeify and !"Gun2D" in str(originator):
		$AnimatedSprite.frame = 2
		damage = 10
	set_global_position(get_global_position()+velocity*delta)
	if Global.rockets and "Gun2D" in str(originator):
		$AnimatedSprite.frame = 1
		damage = 90


func die():
	set_visible(false)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	call_deferred("queue_free")


func _on_Area2D_body_entered(body):
	if body == originator:
		return
	elif body.has_method("hit"):
		var _err = connect("hit", body, "_on_hit")
		emit_signal("hit", damage, velocity)
		die()
	elif body.has_method("_on_hit"):
		var _err = connect("hit", body, "_on_hit")
		emit_signal("hit", damage, velocity)
		die()
	else: # probably hit a wal
		if !(snakeify and !"Gun2D" in str(originator)):
			if Global.rockets:
				$AnimatedSprite.play("impact rockets")	
			else:
				$AnimatedSprite.play("impact")
		velocity = Vector2.ZERO
		$CPUParticles2D.emitting = true

func _on_AnimatedSprite_animation_finished():
	self.die()


func _on_Area2D_area_entered(area):
	if !(snakeify and !"Gun2D" in str(originator)):
		if "Car" in area.name:
			var car = area
			car._on_hit(damage, velocity)
			$AnimatedSprite.play("impact")
			velocity = Vector2.ZERO
			$CPUParticles2D.emitting = true


func _on_LifetimeTimer_timeout():
	if !(snakeify and !"Gun2D" in str(originator)):
		die() # Replace with function body.
