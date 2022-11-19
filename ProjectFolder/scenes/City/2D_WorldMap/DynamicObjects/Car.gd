extends Area2D


var speed = 200.0
var max_speed = 200.0
var steering_speed = 2.0
var health = 100.0
var max_health = 100.0
var crash_vector := Vector2.ZERO
var crash_angular_vel := 3.0
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
		
		var collisionAvoidanceVector = get_collision_avoidance_vector()
		var pathFollowVector = get_path_follow_vector()
		
		var vectors_of_concern = [ collisionAvoidanceVector, pathFollowVector ]

		var averageVector = Vector2.ZERO
		for vector in vectors_of_concern:
			averageVector += vector
		averageVector = averageVector / vectors_of_concern.size()
			
		turn_toward_vector(averageVector, delta)

		
		var movementVector = get_forward_vector().normalized() * speed
		position += movementVector * delta

		
		var targetPos = path_follow_target.get_global_position()
		var myPos = get_global_position()
		var ideal_distance = 250.0
		var dist_sq = myPos.distance_squared_to(targetPos)
		if dist_sq > pow((0.9*ideal_distance),2):
			path_follow_target.slow_down()
		elif dist_sq < pow((1.1*ideal_distance), 2):
			path_follow_target.speed_up()

		update_debug_info(movementVector)
			
	elif State == States.CRASHING:
		var crashVelocity = crash_vector
		var crashAngularVel = crash_angular_vel
		position += crashVelocity * delta
		rotation += crashAngularVel * delta


func update_debug_info(movementVector):
	$DebugInfo.set_global_rotation(0)
	$DebugInfo/IntentionLine2D.points = [Vector2.ZERO, movementVector]
	$DebugInfo/fwdLine2D.points = [Vector2.ZERO, get_forward_vector()]
	$DebugInfo/RotationLabel.text = "rot = " + str(rotation).pad_decimals(2)

func get_path_follow_vector():
	var targetPos = path_follow_target.get_global_position()
	var myPos = get_global_position()
	var vectorToTarget = targetPos - myPos
	return vectorToTarget
	
	
func turn_toward_vector(vector, delta):
	if get_forward_vector().rotated(PI/2).dot(vector) > 0:
		# turn right
		rotation += steering_speed * delta
	else:
		# turn left
		rotation -= steering_speed * delta
	

func get_collision_avoidance_vector():
	var avoidanceVector = get_forward_vector()
	
	if $RayCast2D.is_colliding(): # evasive maneuvers!
		var collisionObject = $RayCast2D.get_collider()
		# try to drive around?
		if "Car" in collisionObject.name:
			var obstaclePos = collisionObject.get_global_position()
			var myPos = get_global_position()
			var impactVector = obstaclePos - myPos
			# figure out if impact vector is left or right of my forward vector
			if get_forward_vector().rotated(PI/2).dot(impactVector) > 0:
				# turn left
				avoidanceVector = get_forward_vector().rotated(-PI/4) * speed
			else:
				avoidanceVector = get_forward_vector().rotated(PI/4) * speed
	return avoidanceVector
			


func get_forward_vector():
	return Vector2.RIGHT.rotated(rotation) * speed


func get_turn_dir(target):
	# dot product of our tangent with vector to target.
	var targetPos = target.get_global_position()
	var myPos = get_global_position()
	var tangentVec = Vector2.RIGHT.rotated(rotation).rotated(PI/2)
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
	
	crash_angular_vel = rand_range(1.0, 3.0)
	if randf()<0.5:
		crash_angular_vel *= -1
		
	$FireballParticles2D.emitting = true
	State = States.CRASHING
	$CrashTimer.start()
	$Sprite.set_z_index(-1)
	$VroomNoise.stop()
	$Headlight.hide()
	path_follow_target.die()
	

func accelerate(delta):
	var throttleForce = 1.0
	speed = min( speed + ( throttleForce * delta ) , max_speed )

	
func brake(delta):
	var brakeForce = 5.0
	speed = max(speed - (brakeForce * delta), 0 )
	
	

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


