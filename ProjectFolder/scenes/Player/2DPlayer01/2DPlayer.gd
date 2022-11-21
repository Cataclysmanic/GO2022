extends KinematicBody2D


export var sprint_velocity_multiple = 1.75
export var player_speed = 325.0
export var max_health = 100.0
onready var space_state = get_world_2d().direct_space_state
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

var FOV_increment = 2 * PI / 60

onready var quest_log = find_node("QuestLog")
onready var quest_notification = find_node("UpdateNotice")


# Called when the node enters the scene tree for the first time.
func _ready():
	update_bars()
	$PaperDoll.relax()
	if Global.IO.player_has_item("gun2D"):
		spawn_item(Global.IO.get_item("Gun2D"))

	manual_spawn_gun() # temporary
	State = States.READY
	$DebugInfo.visible = Global.user_preferences["debug"]
#	set_primary_target_area(get_FOV_circle(Vector2(0,0),500))

	
func init(mapScene):
	map_scene = mapScene
	hud = find_node("HUD")
	health_bar = hud.find_node("HealthBar")
	stamina_bar = hud.find_node("StaminaBar")
	dying_warning_label = hud.find_node("DyingWarningLabel")
	camera = find_node("Camera2D")
	camera.init(self, hud)
	Global.player = self

func update_bars():
	health_bar.value = health
	stamina_bar.value = stamina
	if State == States.DYING:
		dying_warning_label.visible = true
		dying_warning_label.text = "You're dying, find bandages: " + str(int($Timers/DeathTimer.get_time_left()))
	else:
		dying_warning_label.visible = false
		
func update_journal(currentQuest):
	quest_log.quests.append({"type": "Quest:", "quest": str(currentQuest), "status": ""}) 
	quest_notification.show()
	yield(get_tree().create_timer(1.0), "timeout")
	quest_notification.hide()

func complete_quest(currentQuest):
#	$CanvasLayer/HUD/Top/Header/HelpButton/PlayerInstructions/VBoxContainer.complete(currentQuest) WIP
	quest_log.quests.append({"type": "Quest:", "quest": str(currentQuest) , "status": " COMPLETED"}) 
	quest_notification.show()
	yield(get_tree().create_timer(1.0), "timeout")
	quest_notification.hide()
	
func update_item(currentItem):
	quest_log.quests.append({"type": "Item:", "quest": str(currentItem) , "status": " Picked Up"}) 
	quest_notification.show()
	yield(get_tree().create_timer(1.0), "timeout")
	quest_notification.hide()
	
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

func raycast_arc(from:Vector2,radius,start_angle,end_angle):
	var angle = start_angle	
	var points = PoolVector2Array()
	while angle < end_angle:
		var to = Vector2(radius,0).rotated(angle)
		var result = space_state.intersect_ray(from,to,[],1)
		if result:
			points.append(result.position)
		else:
			points.append(to)
		angle += FOV_increment
	return points

func get_FOV_circle(from:Vector2,radius):
	return raycast_arc(from,radius,FOV_increment,2*PI)

func _physics_process(delta):
	if State == States.INITIALIZING:
		return
	elif State != States.DEAD:
		if delta != 0:
			move(delta)
			rotate_melee_attack_zone(delta)
			set_primary_target_area(get_FOV_circle(Vector2(0,0),300))
			$Flashlight.look_at(get_global_mouse_position())
			if stamina < 100 :
				stamina += 1
				update_bars()
	if has_node("DebugInfo"):
		$DebugInfo.text = States.keys()[State]
		
	
	
	
func set_primary_target_area(points:PoolVector2Array):
	pass
	#$PaperDoll/TargetArea/CollisionPolygon2D.polygon = points
	#$PaperDoll/TargetArea/Polygon2D.polygon = points

func _unhandled_input(event):
	if event.is_action_pressed("flashlight") and !dead:
		toggle_flashlight()
	if event.is_action_pressed("melee_attack") and !dead:
		melee_attack()
		

func toggle_flashlight():
	var is_enabled = !$Flashlight.enabled
	$Flashlight.enabled = is_enabled
	if is_enabled:
		$PaperDoll.point_gun()
	else:
		$PaperDoll.relax()


func melee_attack():
	#$PlaceholderMeleeSound.play()
	$PaperDoll.melee_attack()
	var targets = $MeleeAttackZone.get_overlapping_bodies()
	for target in targets:
		if target.has_method("extreme_knock_back"):
			var impactVector = target.global_position - self.global_position
			target.extreme_knock_back(impactVector)
			var meleeAudioFiles = $MeleeAttackZone/MeleeAudio.get_children()
			var randAudio = meleeAudioFiles[randi()%meleeAudioFiles.size()]
			randAudio.set_pitch_scale(rand_range(0.9, 1.1))
			randAudio.play()

func begin_dying():
	# play an animation.
	# give the player a chance to heal up or kill one more guy to save his life?
	$Timers/DeathTimer.start()
	State = States.DYING
	if Global.user_preferences["gore"] == false:
			$BloodDripParticles.texture = null
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


func rotate_melee_attack_zone(_delta):
	$MeleeAttackZone.look_at(get_global_mouse_position())


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
	

func _on_hit(damage : float = 10.0, impactVector : Vector2 = Vector2.ZERO):
	# play a noise, flash the sprite or queue animation, launch particles, start invulnerability timer
	# in some games, taking damage supercharges your adrenaline and you gain speed / damage
	if State == States.INITIALIZING:
		return
	elif not State in [States.INVULNERABLE, States.DYING, States.DEAD]: 
		$HitNoise.play()
		if Global.user_preferences["gore"]:
			$AnimationPlayer.play("hit")
		health -= damage
		update_bars()
		knockback(impactVector.normalized() * damage)
		if health <= 0 and State != States.DYING:
			begin_dying()
		else:
			State = States.INVULNERABLE
			$Timers/InvulnerbailityTimer.start()
		
func knockback(impactVector):
	position += impactVector
		
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
	


func _on_TargetArea_body_entered(body):
	if "Target" in body:
		body.show()

func _on_TargetArea_body_exited(body):
	if "Target" in body:
		body.hide()


func _on_MeleeAttackZone_body_entered(body):
	if body.has_method("extreme_knock_back"):
		melee_attack()
