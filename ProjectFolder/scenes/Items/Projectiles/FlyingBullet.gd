extends Node2D

export var bullet_speed : float
var velocity : Vector2
var damage = 30.0
var originator
var snakeify = false 

signal hit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(source, pos : Vector2, rot : float, speed : float):
	originator = source
	set_global_position(pos)
	set_global_rotation(rot)
	if speed != null:
		bullet_speed = speed
	velocity = (bullet_speed * Vector2.RIGHT.rotated(rot))


func _process(delta):
	if "MookNPC2:" in str(originator):
		set_global_position(get_global_position() + velocity * delta)
		if "Gun2D" in str(originator):
			$CollisionShape2D.disabled=false
	elif !(snakeify and !"Gun2D" in str(originator)):
		set_global_position(get_global_position() + velocity * delta)
		if "Gun2D" in str(originator):
			$CollisionShape2D.disabled=false
	else:
		var direction = get_parent().get_parent().player.self_position - global_position
		var speed = randi()%100+100
		var rotation_speed = randi()%4
		direction = direction.normalized()
		var rotateAmmount = direction.cross(transform.y)
		rotate(rotateAmmount*rotation_speed*delta)
		global_translate((-transform.y*speed*delta))
		
	if snakeify and !"Gun2D" in str(originator):
		$AnimatedSprite.frame = 2
	if Global.rockets and "Gun2D" in str(originator):
		$AnimatedSprite.frame = 1
		damage = 90.0


func die():
	set_visible(false)
	call_deferred("queue_free")
	$BulletArea/CollisionShape2D.call_deferred("set_disabled", true) 
	$CollisionShape2D.call_deferred("set_disabled", true) 

func _on_Area2D_body_entered(body):
	
	if body.is_in_group("Boss"):
		body.boss_hit(damage)
		die()
		#print("Bossy")
	
	
	
	
	if !(snakeify and !"Gun2D" in str(originator)):
		if body == originator:
			return
		elif body.has_method("hit"):
			var _err = connect("hit", body, "_on_hit")
			body.hit()
			die()
		elif body.has_method("_on_hit"):
			var _err = connect("hit", body, "_on_hit")
			body._on_hit()
			die()
			
			
		else: # probably hit a wall
			if Global.rockets:
				$AnimatedSprite.play("impact rockets")	
			elif !snakeify:
				$AnimatedSprite.play("impact")
			velocity = Vector2.ZERO
			$CPUParticles2D.emitting = true
	else: 
		if "Player" in body.name:
			body._on_hit(15)
			

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
	else:
		if "Bullet" in area.name:
			die()

func dummy_emit(): # just to shut up the inspector warnings
	printerr("FlyingBullet.gd deprecated function dummy_emit should not be used")
	if false:
		emit_signal("hit")

func _on_LifetimeTimer_timeout():
	if !snakeify:
		die() # Replace with function body.
