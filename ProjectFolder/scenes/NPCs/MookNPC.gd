extends KinematicBody2D

export var path_to_player := NodePath()
export var has_gun = false # melee or shoot?
var velocity = Vector2.ZERO
onready var nav_agent = $NavigationAgent2D
onready var nav_update_timer = $NavUpdateTimer
onready var sprite = $Sprite
#export var active : bool = false
export var chance_to_have_gun = 0.75
export var chance_to_spawn_loot = 0.25
var health = rand_range(10.0,20.0) # should take 1 or 2 hits to kill them
var map_scene
var home_building
var home_position
var patrol_route_target
var current_path = []
onready var player # map_scene will provide this on init now
var shooting_target_acquired = false
var player_engaged = false
var last_known_target_position: Vector2



onready var gun = $Sprite/NPCGun


enum States { INITIALIZING, READY, PATROLLING, CHASING, SEEKING, FIGHTING, AIMING, RELOADING, DEAD }
var State = States.INITIALIZING setget set_state, get_state
var previous_states = [] # hax! technical_debt. push states onto the stack so you can recall them later? But really, gun states should be separated out from awareness states

onready var character = self

signal loot_ready(lootObj)
signal projectile_ready(bulletObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	#nav_update_timer.connect("timeout", self, "update_nav_path")
	nav_update_timer.start()
	
#	if active:
#		$Label.text = "active"
	
	#nav_agent.set_navigation(home_building.find_node("NPCs"))
	nav_agent.set_navigation(map_scene.find_node("NavPolygons"))
	home_position = get_global_position()

	$DebugInfo.set_visible(Global.user_preferences["debug"])
	find_node("LaserScope").set_visible(Global.user_preferences["debug"])

func init(mapScene, homeBuilding, pathFollowObj):
	map_scene = mapScene
	home_building = homeBuilding
	if pathFollowObj != null:
		patrol(pathFollowObj)
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = mapScene.get_player()

	if randf() < chance_to_have_gun:
		has_gun = true
		$Sprite/NPCGun.show()
		
	else:
		$Sprite/NPCGun.hide()

	jump_out_of_walls()

	set_difficulty(Global.user_preferences["difficulty"])


func set_state(newState):
	# relocate all State = State.whatever statements to set_state, so we can test logic
	store_old_state()
	State = newState


func get_state():
	return State


func store_old_state():
	var numberToStore = 5
	previous_states.push_back(State)
	if previous_states.size() > numberToStore:
		var _discard = previous_states.pop_front()


func patrol(pathFollowObj):
	if pathFollowObj != null and is_instance_valid(pathFollowObj):
		patrol_route_target = pathFollowObj
		set_state(States.PATROLLING)
	

func jump_out_of_walls():
	var overlappingBodies = $damage_area.get_overlapping_bodies()
	if len(overlappingBodies) > 0:
		var averageVector = Vector2.ZERO
		for body in overlappingBodies:
			averageVector += global_position - body.global_position
		set_global_position(global_position + averageVector)
	
	
	
func set_difficulty(difficultyValue): # 0.5 to 3.0
	assert(difficultyValue != 0)
	$Sprite/NPCGun/ReloadTimer.set_wait_time(0.5 / difficultyValue)

func can_seek():
	if State in [ States.DEAD, States.INITIALIZING]:
		return false
	elif player.dead == true:
		return false
#	elif nav_agent.is_target_reachable() == false: # disabling, since player can hide in margin between wall and navmesh
#		return false
	else:
		return true

func can_move():
	if not State in [States.DEAD, States.INITIALIZING, States.AIMING]:
		return true
	else:
		return false


func _physics_process(delta):
	$DebugInfo/StateLabel.text = States.keys()[State]
	$DebugInfo.set_global_rotation(0)

	if State in [States.DEAD, States.INITIALIZING]:
		return
	
	if not State == States.AIMING: # NPCs should pause for a moment after pulling trigger
		if has_gun:
			#turn_toward_player(delta) # move_along_path() already does this?
			if player_in_sights():
				pull_trigger() # starts a short delay timer before bullet emerges
		move_along_path(delta)

	

func player_in_sights():
	var targetted_object = gun.get_node("RayCast2D").get_collider()
	if targetted_object != null and "detective" in targetted_object.name.to_lower():
		return true
	else:
		return false

func turn_toward_player(delta):
	var playerPos = player.get_global_position()
	var myPos = self.get_global_position()
	turn_toward_vector((playerPos - myPos), delta)


func pull_trigger():
	$Sprite/NPCGun/TriggerFingerTimer.start() 
	set_state(States.AIMING)

func move_along_path(delta):
	if State == States.DEAD:
		return
		
	var target_global_position = nav_agent.get_next_location()

	var normalVectorToTarget = global_position.direction_to(target_global_position)

	var desiredvelocity = normalVectorToTarget * nav_agent.max_speed
	var acceleration = (desiredvelocity - velocity) * delta * 4.0
	velocity += acceleration

	if State in [States.FIGHTING, States.CHASING]:
		turn_toward_vector(velocity, delta)
		velocity = move_and_slide(velocity)
	elif State == States.PATROLLING and not near_target(target_global_position, 5.0): # prevent needless spinning?
		turn_toward_vector(velocity, delta)
		velocity = move_and_slide(velocity)
	else: # patrolling, but too close to the nav_target, slow down and don't spin
		velocity = move_and_slide(velocity / 2.0)



func near_target(pos : Vector2, proximity : float):
	if get_global_position().distance_squared_to(pos) < pow(proximity,2):
		return true
	else:
		return false	

func turn_toward_vector(target_vector, delta):
	#sprite.rotation = lerp_angle(sprite.rotation, target_vector.angle(), 10.0 * delta)
	#why do we only rotate the sprite and not the whole entity object?
	rotation = lerp_angle(rotation, target_vector.angle(), 10.0 * delta)
	

func update_nav_path(destination):
	if State == States.DEAD:
		return

	var nav_destination = destination
	nav_agent.set_target_location(nav_destination)
	#current_path = nav_agent.get_nav_path()
	var nav_optimize_path = true
	current_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)
	
	$DebugInfo/Line2D.points = current_path
	$DebugInfo/Line2D.set_global_position(Vector2.ZERO)
	


func flash_hit():
	if Global.user_preferences["gore"]:
		$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	set_state(States.DEAD)
	$DieNoise.play()
	$Corpse.rotation = rand_range(0, 2*PI)
	if Global.user_preferences["gore"]:
		$AnimationPlayer.play("die")
	else:
		set_visible(false)
		call_deferred("queue_free")
	$CollisionShape2D.call_deferred("set_disabled", true)
	spawn_loot()
	if patrol_route_target != null and is_instance_valid(patrol_route_target):
		patrol_route_target.die()

func spawn_loot():
	if randf() < chance_to_spawn_loot:
		var loader = $SpawnOnDeath
		var options = loader.get_resource_list()
		var randOptionName = options[randi()%len(options)]
		var lootObject = loader.get_resource(randOptionName).instance()
		lootObject.set_global_position(get_global_position())
		emit_signal("loot_ready", lootObject)


func shoot(): # this ought to be in a separate gun object
	if not is_connected("projectile_ready", map_scene, "_on_projectile_ready"):
		if map_scene.has_method("_on_projectile_ready"):
			var _err = connect("projectile_ready", map_scene, "_on_projectile_ready")

	# this should all be in a separate gun object, but I'll move it later.
	if has_gun and State == States.AIMING:

		var bullet = gun.get_node("Ammo").get_resource("bullet").instance()
		var pos = gun.get_node("Muzzle").get_global_position()
		var bulletSpeed = 600.0
		bullet.init(self, pos, rotation, bulletSpeed)
		emit_signal("projectile_ready", bullet)
		var gunshotNoises = $Sprite/NPCGun/GunshotNoises.get_children()
		var gunshotNoise = gunshotNoises[randi()%len(gunshotNoises)]
		gunshotNoise.set_pitch_scale(rand_range(0.9, 1.1))
		gunshotNoise.set_volume_db(rand_range(0.9, 1.1))
		gunshotNoise.play()
		$AnimationPlayer.play("shoot")
		$Sprite/NPCGun/ReloadTimer.start()
		set_state(States.RELOADING)


func _on_hit(damage : float = 10.0, incomingVector : Vector2 = Vector2.ZERO):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_hit()
		if incomingVector != Vector2.ZERO:
			knock_back(incomingVector.normalized() * damage)


func extreme_knock_back(impactVector):
	impactVector = impactVector.normalized()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position+(impactVector*60.0), 0.2)
	yield(tween, "finished")
	die()
	


func knock_back(impactVector):
	# ideally we'd tween / lerp to this, but I'll just teleport the NPC backwards for now.
	position += impactVector


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		set_visible(false)
		queue_free()


func _on_damage_area_body_entered(body):
	if State == States.DEAD:
		return
	if body.name == "PlayerDetective":
		body._on_hit(1)


func _on_PunchingArea_body_entered(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		$AnimationPlayer.play("punch")


func _on_PunchingArea_body_exited(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("relax")


func _on_NavUpdateTimer_timeout():
	# set the navigation target and update the NPC state if necessary.
	
	if State == States.DEAD:
		return

	if can_seek():
		if State == States.PATROLLING:
			update_nav_path(patrol_route_target.get_global_position())
		elif State in [ States.CHASING, States.FIGHTING ]:
			update_nav_path(player.get_global_position())
		else: # for cops, because they don't have a patrol route yet?
			update_nav_path(home_position)
		
	else: # player is gone, return to home
		if patrol_route_target != null and is_instance_valid(patrol_route_target):
			update_nav_path(patrol_route_target.get_global_position())
			set_state(States.PATROLLING)
		else:
			update_nav_path(home_position)
			set_state(States.READY)
			
	nav_update_timer.set_wait_time(rand_range(0.5, 1.5))
	nav_update_timer.start()



func _on_ReloadTimer_timeout():
	if not State in [States.DEAD]:
		if State == States.RELOADING:
			set_state(States.FIGHTING)



func _on_TriggerFingerTimer_timeout():
	if State == States.AIMING: # must not be dead then
		shoot()

	
func _on_VisionCone_saw_detective(location):
	if State == States.PATROLLING: # must not be dead then
		set_state(States.CHASING)
		last_known_target_position = location
		# TODO: once we're in a fight, is it safe to disable the vision cone?

