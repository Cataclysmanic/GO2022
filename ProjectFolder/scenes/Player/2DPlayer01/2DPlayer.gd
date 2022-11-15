extends KinematicBody2D


export var sprint_velocity_multiple = 1.75
export var player_speed = 325.0
var map_scene
var camera
var hud
var last_movement_vector = Vector2.ZERO

enum States {INITIALIZING, READY, INVULNERABLE, DYING, DEAD}
var State = States.INITIALIZING

export var health = 50.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$PaperDoll.relax()
	if Global.IO.player_has_item("gun2D"):
		spawn_item(Global.IO.get_item("Gun2D"))

	manual_spawn_gun() # temporary
	State = States.READY

	
func init(mapScene):
	map_scene = mapScene
	hud = find_node("HUD")
	camera = find_node("Camera2D")
	camera.init(self, hud)


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
	move(delta)
	$Flashlight.look_at(get_global_mouse_position())


func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()

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
	
func die_for_real_this_time():
	# ask world_controller to return us to the main menu?
	pass
	
	

func move(_delta):
	# delta not required for move_and_slide

	var speed = player_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_velocity_multiple

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
	if State != States.READY:
		return
	else:
		State = States.INVULNERABLE
		$HitNoise.play()
		$AnimationPlayer.play("hit")
		$Timers/InvulnerbailityTimer.start()
		health -= damage
		if health < 0:
			begin_dying()
	
func _on_InvulnerbailityTimer_timeout():
	State = States.READY
	
func _on_DeathTimer_timeout():
	if health <= 0:
		die_for_real_this_time()
		




