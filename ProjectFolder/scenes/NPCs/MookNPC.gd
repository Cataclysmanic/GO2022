extends KinematicBody2D

export var path_to_player := NodePath()
export var has_gun = false # melee or shoot?
var velocity = Vector2.ZERO
onready var nav_agent = $NavigationAgent2D
onready var nav_update_timer = $NavUpdateTimer
onready var sprite = $Sprite
export var active : bool = false
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
#var ready = false # use State == States.READY instead

onready var gun = $Sprite/NPCGun


enum States { INITIALIZING, READY, CHASING, FIGHTING, AIMING, RELOADING, DEAD }
var State = States.INITIALIZING

onready var character = self

signal loot_ready(lootObj)
signal projectile_ready(bulletObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	#nav_update_timer.connect("timeout", self, "update_nav_path")
	nav_update_timer.start()
	
	if active:
		$Label.text = "active"
	
	State = States.READY
	#nav_agent.set_navigation(home_building.find_node("NPCs"))
	nav_agent.set_navigation(map_scene.find_node("NavPolygons"))

	home_position = get_global_position()


func init(mapScene, homeBuilding, pathFollowObj):
	map_scene = mapScene
	home_building = homeBuilding
	if pathFollowObj != null:
		patrol_route_target = pathFollowObj
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = mapScene.get_player()

	if randf() < chance_to_have_gun:
		has_gun = true
		$Sprite/NPCGun.show()
	else:
		$Sprite/NPCGun.hide()

	jump_out_of_walls()

	set_difficulty(Global.user_preferences["difficulty"])
	

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
	if (
		State == States.DEAD
		or (!nav_agent.is_target_reachable())
		#or (!home_building.is_player_present() and !player_engaged)
		#or nav_agent.is_navigation_finished()
		#or len(current_path) == 0
		or player.dead
	):
		return false
	else:
		return true

func can_move():
	if not State in [States.DEAD, States.INITIALIZING, States.AIMING]:
		return true
	else:
		return false


func _physics_process(delta):
	if can_move():
		if shooting_target_acquired and has_gun and State == States.READY:
			turn_toward_player(delta)
			if player_in_sights():
				pull_trigger() # starts a short delay timer before bullet emerges
		move_along_path(delta)


func player_in_sights():
	var targetted_object = gun.get_node("RayCast2D").get_collider()
	if targetted_object != null and "detective" in targetted_object.name.to_lower():
		player_engaged = true
		return true
	else:
		return false

func turn_toward_player(delta):
	var playerPos = player.get_global_position()
	var myPos = self.get_global_position()
	turn_toward_vector((playerPos - myPos), delta)


func pull_trigger():
	$Sprite/NPCGun/TriggerFingerTimer.start() 
	State = States.AIMING

func move_along_path(delta):
	var target_global_position = nav_agent.get_next_location()

	var direction = global_position.direction_to(target_global_position)

	var desiredvelocity = direction * nav_agent.max_speed
	var steering = (desiredvelocity - velocity) * delta * 4.0
	velocity += steering

	velocity = move_and_slide(velocity)
	turn_toward_vector(velocity, delta)

func turn_toward_vector(target_vector, delta):
	sprite.rotation = lerp_angle(sprite.rotation, target_vector.angle(), 10.0 * delta)
	#why do we only rotate the sprite and not the whole entity object?
	

func update_nav_path(destination):
	var nav_destination = destination
	nav_agent.set_target_location(nav_destination)
	#current_path = nav_agent.get_nav_path()
	var nav_optimize_path = true
	current_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)
	
	$Line2D.points = current_path
	$Line2D.set_global_position(Vector2.ZERO)
	


func flash_hit():
	if Global.user_preferences["gore"]:
		$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	State = States.DEAD
	$DieNoise.play()
	$Corpse.rotation = rand_range(0, 2*PI)
	if Global.user_preferences["gore"]:
		$AnimationPlayer.play("die")
	else:
		set_visible(false)
		call_deferred("queue_free")
	$CollisionShape2D.call_deferred("set_disabled", true)
	spawn_loot()

func spawn_loot():
	if randf() < chance_to_spawn_loot:
		var loader = $SpawnOnDeath
		var options = loader.get_resource_list()
		var randOptionName = options[randi()%len(options)]
		var lootObject = loader.get_resource(randOptionName).instance()
		lootObject.set_global_position(get_global_position())
		emit_signal("loot_ready", lootObject)


func shoot():
	if not is_connected("projectile_ready", map_scene, "_on_projectile_ready"):
		if map_scene.has_method("_on_projectile_ready"):
			var _err = connect("projectile_ready", map_scene, "_on_projectile_ready")

	# this should all be in a separate gun object, but I'll move it later.
	if has_gun and State == States.AIMING:

		var bullet = gun.get_node("Ammo").get_resource("bullet").instance()
		var pos = gun.get_node("Muzzle").get_global_position()
		var bulletSpeed = 600.0
		bullet.init(self, pos, $Sprite.rotation, bulletSpeed)
		emit_signal("projectile_ready", bullet)
		var gunshotNoises = $Sprite/NPCGun/GunshotNoises.get_children()
		var gunshotNoise = gunshotNoises[randi()%len(gunshotNoises)]
		gunshotNoise.set_pitch_scale(rand_range(0.9, 1.1))
		gunshotNoise.set_volume_db(rand_range(0.9, 1.1))
		gunshotNoise.play()
		$AnimationPlayer.play("shoot")
		$Sprite/NPCGun/ReloadTimer.start()
		State = States.RELOADING
		


func _on_hit(damage : float = 10.0, incomingVector : Vector2 = Vector2.ZERO):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_hit()
		if incomingVector != Vector2.ZERO:
			knock_back(incomingVector.normalized() * damage)
		

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
	if can_seek():
		if patrol_route_target != null:
			update_nav_path(patrol_route_target.get_global_position())
		else:
			update_nav_path(player.get_global_position())
		
	else:
		if patrol_route_target != null:
			update_nav_path(patrol_route_target.get_global_position())
		else:
			update_nav_path(home_position)
	nav_update_timer.set_wait_time(rand_range(0.5, 1.5))
	nav_update_timer.start()


func _on_ShootingArea_body_entered(body):
	if "detective" in body.name.to_lower():
		if has_gun:
			shooting_target_acquired = true



func _on_ShootingArea_body_exited(body):
	if "detective" in body.name.to_lower():
		if has_gun:
			shooting_target_acquired = false



func _on_ReloadTimer_timeout():
	if State == States.RELOADING:
		State = States.READY



func _on_TriggerFingerTimer_timeout():
	shoot()
	

