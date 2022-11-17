extends PathFollow2D

var speed = 200.0
var health = 100.0
var max_health = 100.0
var crash_vector := Vector2.ZERO

# maybe player should be able to shoot cars.. or they take damage from collisions. later

enum States { INITIALIZING, READY, MOVING, CRASHING, WRECKED }
var State = States.INITIALIZING


export var damage = 40.0
signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State in [ States.READY, States.MOVING ]:
		set_offset(get_offset()+speed * delta)
	elif State == States.CRASHING:
		var crashVelocity = crash_vector
		var crashAngularVel = 3.0
		position += crashVelocity * delta
		rotation += crashAngularVel * delta
		

func _on_hit(hitDamage, impactVector):
	# change the sprite to a damaged version?
	# add decals to represent damage?
	
	health -= hitDamage

	var damageColorComponent = 1.0
	damageColorComponent = health/max_health
	var damageColor = Color(damageColorComponent,damageColorComponent,damageColorComponent)
	$Sprite.self_modulate = damageColor

	if health <= 0:
		if not State in [ States.CRASHING, States.WRECKED]:
			wreck()
		else: # already crashing or dead
			knockback(impactVector, 10.0)
			

func knockback(impactVector, magnitude = 10.0):
	position += impactVector.normalized() * magnitude


func wreck():
	# what should this look like? 
		# Explosion, spin out of control?
	crash_vector = Vector2(speed + rand_range(-50.0, 50.0), rand_range(-20.0, 20.0)).rotated(global_rotation)
	$FireballParticles2D.emitting = true
	State = States.CRASHING
	$CrashTimer.start()
	

func _on_Area2D_body_entered(body):
	if body.has_method("_on_hit"):
		var _err = connect("hit", body, "_on_hit")
	elif body.has_method("hit"):
		var _err = connect("hit", body, "hit")
	emit_signal("hit", damage)


func _on_CrashTimer_timeout():
	State = States.WRECKED


func _on_Area2D_area_entered(area):
	var impactVector = self.get_global_position() - area.get_global_position()

	if not State in [ States.CRASHING, States.WRECKED ]:
		if "Car" in area.get_parent().name:
			_on_hit(100.0, impactVector)
	else:
		knockback(impactVector, 10.0)
