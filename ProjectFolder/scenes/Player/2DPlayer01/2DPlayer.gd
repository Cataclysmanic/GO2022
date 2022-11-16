extends KinematicBody2D


export var sprint_velocity_multiple = 1.75
export var player_speed = 325.0
export var max_health = 100.0

var map_scene
var camera
var hud
var health_bar

var stamina_bar
var dying_warning_label

var last_movement_vector = Vector2.ZERO

enum States {INITIALIZING, READY, INVULNERABLE, DYING, DEAD}
var State = States.INITIALIZING

var health = 100
var stamina = 100
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	update_bars()
	$PaperDoll.relax()
	if Global.IO.player_has_item("gun2D"):
		spawn_item(Global.IO.get_item("Gun2D"))

	manual_spawn_gun() # temporary
	State = States.READY

	
func init(mapScene):
	map_scene = mapScene
	hud = find_node("HUD")
	health_bar = hud.find_node("HealthBar")
	stamina_bar = hud.find_node("StaminaBar")
	dying_warning_label = hud.find_node("DyingWarningLabel")
	camera = find_node("Camera2D")
	camera.init(self, hud)

func update_bars():
	health_bar.value = health
	stamina_bar.value = stamina
	if State == States.DYING:
		dying_warning_label.visible = true
		dying_warning_label.text = "You're dying, find bandades: " + str(int($Timers/DeathTimer.get_time_left()))
	else:
		dying_warning_label.visible = false

func has_item(itemName):
	return Global.IO.player_has_item(itemName)

func is_player():
	return true

func spawn_item(itemRes):
	var itemScene
	if itemRes.path_to_scene_for_PlayerController_Items != null:
		itemScene = itemRes.path_to_scene_for_PlayerController_Items
		$Items.add_child(itemScene)



	elif itemRes.item_name.to_lower() == "gun" or itemRes.item_name.to_lower() == "gun2d":
		manual_spawn_gun()



func manual_spawn_gun():
	var gunScene = $ResourcePreloader.get_resource("Gun2D").instance()
	var loc = find_node("GunLocation")
	
	gunScene.init(map_scene, self, self.get_hud())
	loc.add_child(gunScene)
	

func get_hud():
	return hud


func _physics_process(delta):
	if State == States.INITIALIZING:
		return
	elif State != States.DEAD:
		move(delta)
		$Flashlight.look_at(get_global_mouse_position())
		if stamina < 100 :
			stamina += 1
			update_bars()
	if has_node("DebugInfo"):
		$DebugInfo.text = States.keys()[State]


func _unhandled_input(event):
	if event.is_action_pressed("flashlight") and !dead:
		toggle_flashlight()
	if event.is_action_pressed("melee_attack") and !dead:
		$PlaceholderMeleeSound.play()
		$PaperDoll/AnimationPlayer.play("placeholderMelee")

func toggle_flashlight():
	var is_enabled = !$Flashlight.enabled
	$Flashlight.enabled = is_enabled
	if is_enabled:
		$PaperDoll.point_gun()
	else:
		$PaperDoll.relax()


func begin_dying():
	# play an animation.
	# give the player a chance to heal up or kill one more guy to save his life?
	$Timers/DeathTimer.start()
	State = States.DYING
	$AnimationPlayer.play("dying")
	dying_warning_label.visible = true
	$Timers/DyingWarningUpdateTimer.start()

func recover_from_near_death():
	# player found a bandage after dying process started.
	# Celebrate and give max_health
		
	dying_warning_label.hide()
	State = States.READY
	health = max_health
	$RecoveryNoise.set_pitch_scale(rand_range(0.9, 1.1))
	$RecoveryNoise.play()
	$RecoveryFireworks.emitting = true
	$BloodDripParticles.emitting = false
	update_bars()

func die_for_real_this_time():
	dead = true
	State = States.DEAD
	$DeathScream.play()
	$PaperDoll.hide()
	$deadPlaceholder.show()

func move(_delta):
	# delta not required for move_and_slide

	var speed = player_speed
	if Input.is_action_pressed("sprint") and stamina > 0:
		speed *= sprint_velocity_multiple
		stamina -= 2
		update_bars()
	
	var move_vector = Vector2.ZERO
	var directional_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		$PaperDoll/Lower.rotation_degrees = -90
		move_vector += Vector2.UP * speed
	if Input.is_action_pressed("ui_left"):
		$PaperDoll/Lower.rotation_degrees = 180
		move_vector += Vector2.LEFT * speed
	if Input.is_action_pressed("ui_right"):
		$PaperDoll/Lower.rotation_degrees = 0
		move_vector += Vector2.RIGHT * speed
	if Input.is_action_pressed("ui_down"):
		$PaperDoll/Lower.rotation_degrees = 90
		move_vector += Vector2.DOWN * speed
	directional_vector = move_vector

	var _collision = move_and_slide(directional_vector) # move and slide doesn't use delta.
	play_animations(directional_vector)
	last_movement_vector = directional_vector
	
	
func play_animations(movement_vector):
	var currentSpeedSq = movement_vector.length_squared()
	var previousSpeedSq = last_movement_vector.length_squared()
	
	var faster_than_before = currentSpeedSq > previousSpeedSq
	var slower_than_before = previousSpeedSq > currentSpeedSq
	
	if faster_than_before:
		if Input.is_action_pressed("sprint"):
			$PaperDoll.start_running()
		else:
			$PaperDoll.start_walking()
	elif slower_than_before:
		
		if movement_vector != Vector2.ZERO:
			$PaperDoll.start_walking()
		else:
			$PaperDoll.relax()
	
func _on_collectible_picked_up(_pickupObj):
	pass # don't really care yet. Inventory and IO can hash this out between them.
	

func _on_hit(damage):
	# play a noise, flash the sprite or queue animation, launch particles, start invulnerability timer
	# in some games, taking damage supercharges your adrenaline and you gain speed / damage
	if State == States.INITIALIZING:
		return
	elif not State in [States.INVULNERABLE, States.DYING, States.DEAD]: 
		$HitNoise.play()
		$AnimationPlayer.play("hit")
		health -= damage
		update_bars()
		if health <= 0 and State != States.DYING:
			begin_dying()
		else:
			State = States.INVULNERABLE
			$Timers/InvulnerbailityTimer.start()
		
func _on_healed(amount):
	if health < max_health:
		health = min(health + amount, max_health)
		update_bars()
	if State == States.DYING:
		recover_from_near_death()


func _on_InvulnerbailityTimer_timeout():
	if health > 0:
		State = States.READY
	
		
	
func _on_DeathTimer_timeout():
	if health <= 0:
		die_for_real_this_time()
		






func _on_DyingWarningUpdateTimer_timeout():
	update_bars()
	if health <= 0:
		$Timers/DyingWarningUpdateTimer.start()
	# no need to recover here, the bandage calls recover_from_near_death
	
