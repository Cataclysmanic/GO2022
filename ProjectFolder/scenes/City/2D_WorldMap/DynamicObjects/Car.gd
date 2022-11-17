extends PathFollow2D

var speed = 200.0
var health = 100.0
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


func _on_hit(damage, impactVector):
	# change the sprite to a damaged version?
	# add decals to represent damage?
	
	health -= damage
	
	if health <= 0:
		wreck()
		

func wreck():
	# what should this look like? 
		# Explosion, spin out of control?
	$FireballParticles2D.emitting = true
	


func _on_Area2D_body_entered(body):
	if body.has_method("_on_hit"):
		var _err = connect("hit", body, "_on_hit")
	elif body.has_method("hit"):
		var _err = connect("hit", body, "hit")
	emit_signal("hit", damage)
