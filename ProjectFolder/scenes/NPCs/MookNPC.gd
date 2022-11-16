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
var health = 20.0
var map_scene
var home_building
var current_path = []
onready var player # map_scene will provide this on init now
var shooting_target_acquired = false
var player_engaged = false
#var ready = false # use State == States.READY instead

enum States { INITIALIZING, READY, CHASING, FIGHTING, RELOADING, DEAD }
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

func init(mapScene, homeBuilding):
	map_scene = mapScene
	home_building = homeBuilding
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = mapScene.get_player()

	if randf() < chance_to_have_gun:
		has_gun = true
		$Sprite/NPCGun.show()
	else:
		$Sprite/NPCGun.hide()


func can_seek():
		
	
	if (
		State == States.DEAD
		or (!nav_agent.is_target_reachable() and !player_engaged)
		or (!home_building.is_player_present() and !player_engaged)
		or nav_agent.is_navigation_finished()
		or len(current_path) == 0
		or player.dead
	):
		return false
	else:
		return true


func _physics_process(delta):
	
	if can_seek():
		if shooting_target_acquired and has_gun and State == States.READY:
			var playerPos = player.get_global_position()
			var myPos = self.get_global_position()
			turn_toward_vector((playerPos - myPos), delta)
			shoot()
		else:
			move_along_path(delta)


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
	

func update_nav_path():
	var nav_destination = player.get_global_position()
	nav_agent.set_target_location(nav_destination)
	#current_path = nav_agent.get_nav_path()
	var nav_optimize_path = true
	current_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)

	if can_seek():
		$Line2D.points = current_path
		$Line2D.set_global_position(Vector2.ZERO)
	else:
		$Line2D.points = []



func flash_hit():
	$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	State = States.DEAD
	$DieNoise.play()
	$Corpse.rotation = rand_range(0, 2*PI)
	$AnimationPlayer.play("die")
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
	if has_gun and shooting_target_acquired and State == States.READY:
		
		var gun = $Sprite/NPCGun
		var targetted_object = gun.get_node("RayCast2D").get_collider()
		if targetted_object != null and "detective" in targetted_object.name.to_lower():
			player_engaged = true
			var bullet = gun.get_node("Ammo").get_resource("bullet").instance()
			var pos = gun.get_node("Muzzle").get_global_position()
			var bulletSpeed = 400.0
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
			


func _on_hit(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_hit()
		

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
	
	update_nav_path()
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

