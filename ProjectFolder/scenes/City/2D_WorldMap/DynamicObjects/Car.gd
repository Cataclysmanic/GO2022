extends Area2D


var speed = 200.0
var max_speed = 200.0
var steering_speed = 10.0
var health = 100.0
var max_health = 100.0
var crash_vector := Vector2.ZERO
var path_follow_target : PathFollow2D

# maybe player should be able to shoot cars.. or they take damage from collisions. later

enum States { INITIALIZING, READY, MOVING, CRASHING, WRECKED }
var State = States.INITIALIZING


export var damage = 40.0
signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY

func init(pathFollowNode):
	path_follow_target = pathFollowNode
	set_global_position(path_follow_target.get_global_position()+Vector2.RIGHT)
	rotate(PI)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State in [ States.READY, States.MOVING ]:
		if $RayCast2D.is_colliding(): # evasive maneuvers!
			var collisionObject = $RayCast2D.get_collider()
			# try to drive around?
			if "Car" in collisionObject.name:
				speed = max(speed - (3.0 * delta), max_speed / 2.0)
				rotation -= steering_speed * get_turn_dir(collisionObject) * delta
		else: # no obstacles, head for the path_follow_target
			speed = min(speed + (3.0 * delta), max_speed)
			rotation += steering_speed * get_turn_dir(path_follow_target) * delta

		var myForwardVector = Vector2.RIGHT.rotated(rotation)
		var movementVector = myForwardVector * speed
		position += movementVector * delta
			
		var targetPos = path_follow_target.get_global_position()
		var myPos = get_global_position()
		var ideal_distance = 250.0
		var dist_sq = myPos.distance_squared_to(targetPos)
		if dist_sq > pow((0.9*ideal_distance),2):
			path_follow_target.slow_down()
		elif dist_sq < pow((1.1*ideal_distance), 2):
			path_follow_target.speed_up()

			
			
	elif State == States.CRASHING:
		var crashVelocity = crash_vector
		var crashAngularVel = 3.0
		position += crashVelocity * delta
		rotation += crashAngularVel * delta

func get_turn_dir(target):
	# dot product of our tangent with vector to target.
	var targetPos = target.get_global_position()
	var myPos = get_global_position()
	var tangentVec = Vector2.DOWN.rotated(rotation)
	var targetVec = targetPos - myPos
	var dotProd = tangentVec.dot(targetVec)
	var safe_range = 3.0
	if abs(dotProd) < safe_range:
		return 0
	elif dotProd < 0:
		return -1
	else:
		return 1
		
	

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
	$Sprite.set_z_index(-1)
	

func _on_Car_body_entered(body):
	if not State in [States.WRECKED]: # don't harm humans after wrecking
		if body.has_method("_on_hit"):
			var _err = connect("hit", body, "_on_hit")
		elif body.has_method("hit"):
			var _err = connect("hit", body, "hit")
		emit_signal("hit", damage)


func _on_CrashTimer_timeout():
	State = States.WRECKED


func _on_Car_area_entered(area):
	var impactVector = self.get_global_position() - area.get_global_position()

	if not State in [ States.CRASHING, States.WRECKED ]:
		if "Car" in area.name:
			_on_hit(100.0, impactVector)
	else:
		knockback(impactVector, 10.0)


