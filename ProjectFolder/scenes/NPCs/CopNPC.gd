extends KinematicBody2D

export var path_to_player := NodePath()
export var has_gun = true # melee or shoot?
var velocity = Vector2.ZERO
onready var nav_agent = $NavigationAgent2D
onready var nav_update_timer = $NavUpdateTimer
onready var sprite = $Sprite
#export var active : bool = false
export var npc_type_odds = { 
	"GunCop":1.0,
}

#chance_to_have_gun = 0.75

export var magazine_size = 6
var ammo_remaining = magazine_size
export var chance_to_spawn_loot = 0.33
var health = rand_range(30.0,50.0) # should take 3 or more shots to kill a cop
var map_scene
var home_building # deprecated. should be safe to remove, so long as init's get changed elsewhere
var home_position
var patrol_route_target
var current_path = []
onready var player # map_scene will provide this on init now
var shooting_target_acquired = false
var player_engaged = false
var last_known_target_position: Vector2

var rotate_sprite : bool = false
var flip_sprite : bool = true

var paper_doll
var currentNpc
var set_boss = 0


onready var gun


enum States { INITIALIZING, READY, PATROLLING, CHASING, SEEKING, FIGHTING, AIMING, RELOADING, FLYING, DEAD }
var State = States.INITIALIZING setget set_state, get_state
var previous_states = [] # hax! technical_debt. push states onto the stack so you can recall them later? But really, gun states should be separated out from awareness states

onready var character = self

signal loot_ready(lootObj)
signal projectile_ready(bulletObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(set_boss)
	gun = find_node("NPCGun")
	#nav_update_timer.connect("timeout", self, "update_nav_path")
	nav_update_timer.start()
	
#	if active:
#		$Label.text = "active"
	
	#nav_agent.set_navigation(home_building.find_node("NPCs"))
	if map_scene != null:
		nav_agent.set_navigation(map_scene.find_node("NavPolygons"))
	home_position = get_global_position()

	$DebugInfo.set_visible(Global.user_preferences["debug"])
	#$DebugInfo.set_visible(true)
	
	var laser = find_node("LaserScope")
	if laser != null:
		laser.set_visible(Global.user_preferences["debug"])
		#laser.set_visible(true)

	if map_scene == null: # the map should have initialized you, but didn't. NP, Do it yourself.
		printerr("CopNPC.gd: NPC spawned, but map didn't initialize it. Doing it manually")
		yield(get_tree().create_timer(0.75), "timeout") # give the city time to get ready
		init( Global.current_city_map, null, null )
		#set_state(States.PATROLLING)


func init(mapScene, homeBuilding, pathFollowObj):
	gun = find_node("NPCGun")
	map_scene = mapScene
	home_building = homeBuilding
	if pathFollowObj != null:
		patrol(pathFollowObj)
	else: # spawn your own
		pathFollowObj = spawn_patrol_route()
		patrol(pathFollowObj)
	if mapScene != null and is_instance_valid(mapScene) and mapScene.has_method("_on_loot_ready"):
		var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = Global.player

	var cumulative_odds = 0.0
	var diceRoll = randf()
	var chosenType : String = ""
	for npcTypeName in npc_type_odds.keys():
		if chosenType == "":
			cumulative_odds += npc_type_odds[npcTypeName]
			if diceRoll < cumulative_odds:
				chosenType = npcTypeName
	assert(chosenType != "")
	spawn_sprite(chosenType)

	jump_out_of_walls()

	set_difficulty(Global.user_preferences["difficulty"])


func spawn_patrol_route():
	var patrolScene = $ResourcePreloader.get_resource("TinyPatrolRoute").instance()
	get_parent().add_child(patrolScene) # not usually how I'd do this, but time crunch.
	patrol_route_target = patrolScene.spawn_path_follower()
	return patrol_route_target

func spawn_sprite(spriteName):
	currentNpc = spriteName
	if has_node("Sprite/vizSpriteHiddenInCode"):
		$Sprite/vizSpriteHiddenInCode.hide()
	var spriteScene
	spriteScene = $ResourcePreloader.get_resource(spriteName).instance()
	rotate_sprite = false
	flip_sprite = true

	if randf() < 0.2:
		has_gun = false

	if spriteScene.has_method("init"):
		spriteScene.init(self)
	spriteScene.name = "PaperDoll"
	$Sprite.add_child(spriteScene)
	


func set_state(newState):
	# relocate all State = State.whatever statements to set_state, so we can test logic
	store_old_state()
	State = newState

	if newState == States.CHASING:
		spawn_alert_sprite()
		

func get_state():
	return State


func store_old_state():
	var numberToStore = 5
	previous_states.push_back(State)
	if previous_states.size() > numberToStore:
		var _discard = previous_states.pop_front()


func spawn_alert_sprite():
	var alertedSprite = $ResourcePreloader.get_resource("AlertedSprite").instance()
	alertedSprite.position = Vector2.ZERO
	alertedSprite.name = "AlertedSprite"
	add_child(alertedSprite)


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
	if gun != null:
		gun.get_node("ReloadTimer").set_wait_time(0.5 / difficultyValue)

func can_seek():
	if State in [ States.DEAD, States.INITIALIZING]:
		return false
	elif player == null or player.dead == true:
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
			if player_in_sights():
				pull_trigger() # starts a short delay timer before bullet emerges
		move_along_path(delta)

	

func player_in_sights():
	var targetted_object = gun.get_node("RayCast2D").get_collider()
	if targetted_object != null and "detective" in targetted_object.name.to_lower():
		return true
	else:
		return false




func pull_trigger():
	gun.get_node("TriggerFingerTimer").start() 
	face_player()
	set_state(States.AIMING)

func move_along_path(delta):
	if State == States.DEAD:
		return
	elif State == States.FLYING:
		var collision = move_and_collide(velocity * delta)
		if collision:
			gib()
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

func turn_toward_player(delta):
	var playerPos = player.get_global_position()
	var myPos = self.get_global_position()
	turn_toward_vector((playerPos - myPos), delta)

func face_player():
	var playerPos = player.get_global_position()
	var myPos = self.get_global_position()
	if playerPos.x > myPos.x:
		$Sprite.scale.x = abs($Sprite.scale.x)
	else:
		$Sprite.scale.x = -abs($Sprite.scale.x)

func turn_toward_vector(target_vector, delta):
	rotation = lerp_angle(rotation, target_vector.angle(), 10.0 * delta)
	rotate_and_flip_sprite(velocity)

func rotate_and_flip_sprite(dirVector):
	if rotate_sprite == false:
		$Sprite.set_global_rotation(0.0)
	#if flip_sprite == true and State != States.AIMING:
	if flip_sprite == true:
		
		if dirVector.x > 0:
			$Sprite.scale.x = abs($Sprite.scale.x)
		else:
			$Sprite.scale.x = -abs($Sprite.scale.x)



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
		var doll = sprite.get_node("PaperDoll")
		if doll.has_method("hit"):
			doll.hit()
			$BloodSpurtParticles.emitting = true
	$HitNoise.play()


func gib():
	$Gibs.set_emitting(true)
	

func die():
	set_state(States.DEAD)
	if has_node("AlertedSprite"):
		get_node("AlertedSprite").queue_free()
	$DieNoise.play()
	#$Corpse.rotation = rand_range(0, 2*PI)
	if Global.user_preferences["gore"]:
		var doll = sprite.get_node("PaperDoll")
		if doll.has_method("die"):
			doll.die()
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
	if map_scene != null and is_instance_valid(map_scene) and map_scene.has_method("_on_projectile_ready"):
		if not is_connected("projectile_ready", map_scene, "_on_projectile_ready"):
			var _err = connect("projectile_ready", map_scene, "_on_projectile_ready")

	# this should all be in a separate gun object, but I'll move it later.
	if has_gun and State == States.AIMING and !player.dead and ammo_remaining > 0:

		var bullet = gun.get_node("Ammo").get_resource("bullet").instance()
		var pos = gun.get_node("Muzzle").get_global_position()
		var bulletSpeed = 600.0
		
		#$NPCGun/TriggerFingerTimer.wait_time = 1.5
		#$NPCGun/ReloadTimer.wait_time = 1.5
		ammo_remaining -= 1
		bullet.init(self, pos, rotation, bulletSpeed)
		
		if map_scene != null and is_instance_valid(map_scene):
			emit_signal("projectile_ready", bullet)
		else:
			get_parent().add_child(bullet)
		
		var gunshotNoises = gun.get_node("GunshotNoises").get_children()
		var gunshotNoise = gunshotNoises[randi()%len(gunshotNoises)]
		gunshotNoise.set_pitch_scale(rand_range(0.9, 1.1))
		gunshotNoise.set_volume_db(rand_range(0.9, 1.1))

		gunshotNoise.play()
		if $Sprite.find_node("AnimationPlayer") and $Sprite/AnimationPlayer.has_animation("shoot"):
			$Sprite/AnimationPlayer.play("shoot")
		gun.get_node("TriggerFingerTimer").start()
		set_state(States.AIMING)
	elif ammo_remaining == 0:
		set_state(States.RELOADING)
		gun.get_node("ReloadTimer").start()

func _on_hit(damage : float = 10.0, incomingVector : Vector2 = Vector2.ZERO):
	health -= damage
	if health <= 0:
		knock_back(incomingVector.normalized() * 3.0 * damage)
		die()
	else:
		flash_hit()
		if incomingVector != Vector2.ZERO:
			knock_back(incomingVector.normalized() * damage)


func extreme_knock_back(impactVector):
	# not sure these are working.. seems to collide with player still.
	set_collision_layer_bit(1, false)
	set_collision_mask_bit(0, false) # ignore player
	set_collision_mask_bit(1, false) # ignore NPCs
	set_collision_mask_bit(4, false) # ignore bullets

	impactVector = impactVector.normalized()
	
	velocity = impactVector * rand_range(900.0, 2200.0)
	velocity = velocity.rotated(rand_range(-PI/4.0, PI/4.0))
	set_state(States.FLYING)
	
#	var tween = get_tree().create_tween()
#	tween.tween_property(self, "position", position+(impactVector*60.0), 0.2)
#	yield(tween, "finished")
	yield(get_tree().create_timer(0.25), "timeout")
	die()
	


func knock_back(impactVector):
	# ideally we'd tween / lerp to this, but I'll just teleport the NPC backwards for now.
	var _collision = move_and_collide(impactVector)
	#position += impactVector


#func _on_AnimationPlayer_animation_finished(anim_name):
#	if anim_name == "die":
#		set_visible(false)
#		queue_free()


func _on_damage_area_body_entered(body):
	if State == States.DEAD:
		return
	if body.name == "PlayerDetective":
		body._on_hit(1)


func _on_PunchingArea_body_entered(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		if $Sprite.find_node("AnimationPlayer") and $Sprite/AnimationPlayer.has_animation("punch"):
			$Sprite/AnimationPlayer.play("punch")


func _on_PunchingArea_body_exited(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		if $Sprite.find_node("AnimationPlayer") and $Sprite/AnimationPlayer.has_animation("relax"):
			$Sprite/AnimationPlayer.stop(true)
			$Sprite/AnimationPlayer.play("relax")


func _on_NavUpdateTimer_timeout():
	# set the navigation target and update the NPC state if necessary.
	
	if State == States.DEAD:
		return

	if can_seek():
		if State == States.PATROLLING:
			if patrol_route_target != null and is_instance_valid(patrol_route_target):
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
			ammo_remaining = magazine_size
			set_state(States.FIGHTING)



func _on_TriggerFingerTimer_timeout():
	if State == States.AIMING: # must not be dead then
		shoot()

	
func _on_VisionCone_saw_detective(location):
	if State == States.PATROLLING: # must not be dead then
		set_state(States.CHASING)
		last_known_target_position = location
		# TODO: once we're in a fight, is it safe to disable the vision cone?

func _on_noise_nearby(location):
	if State == States.PATROLLING: # must not be dead then
		set_state(States.CHASING)
		last_known_target_position = location
	



