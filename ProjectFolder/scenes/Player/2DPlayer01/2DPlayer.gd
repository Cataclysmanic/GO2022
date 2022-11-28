extends KinematicBody2D


export var dash_velocity_multiple = 10.0
export var dash_stamina_cost = 25.0
export var min_dash_stamina_requirement = 50.0
export var stamina_recovery_rate = 25.0
export var max_stamina = 100.0
export var player_speed = 375.0
export var max_health = 100.0

onready var space_state = get_world_2d().direct_space_state
var map_scene
var camera
var hud
var health_bar

var stamina_bar
var dying_warning_label

var weapon

var evidence := 0 # just a number from 0 to 100 indicating how much loot player picked up. Simple in-game currency/reward system.
var evidence_bar

var last_movement_vector = Vector2.ZERO

enum States {INITIALIZING, READY, INVULNERABLE, DASHING, DYING, DEAD}
var State = States.INITIALIZING
var previous_states = [] # stack of previous states, allows us to revert state after dashing, etc.

var health = 100
var stamina = 100
var dead = false
var self_position

var FOV_increment = 2 * PI / 60

onready var quest_log = find_node("QuestLog")
onready var quest_notification = find_node("UpdateNotice")


# Called when the node enters the scene tree for the first time.
func _ready():
	update_bars()
	$PaperDoll.relax()
	
	#if Global.IO.player.has_item("gun2D"): # <-- legacy from version 0.1 on Nov 1. We originally thought the player might not always have a weapon
	#spawn_item(Global.IO.get_item("Gun2D"))

	manual_spawn_gun() # temporary
	$DebugInfo.visible = Global.user_preferences["debug"]
#	set_primary_target_area(get_FOV_circle(Vector2(0,0),500))
	
	if get_tree().get_nodes_in_group("Boss").size() != 0:
		var boss = get_tree().get_nodes_in_group("Boss")[0]
		$CanvasLayer/HUD._on_boss_spawned(boss.health, boss.boss_name)
	
	# fallback safety protocol
	yield(get_tree().create_timer(0.25), "timeout") # give the city time to get ready
	if Global.player == null: # no scene called our init() method
		init(null)
		update_bars()
		
	set_state(States.READY)
	
	
func init(mapScene):
	map_scene = mapScene
	hud = find_node("HUD")
	health_bar = hud.find_node("HealthBar")
	stamina_bar = hud.find_node("StaminaBar")
	evidence_bar = hud.find_node("EvidenceBar")
	dying_warning_label = hud.find_node("DyingWarningLabel")
	camera = find_node("Camera2D")
	camera.init(self, hud)
	Global.player = self

func set_state(state):
	previous_states.push_back(State)
	State = state # current state is not on the stack, only previous states
	
func get_state():
	return State
	
func revert_state():
	State = previous_states.pop_back()
	

func update_bars():
	if not State in [States.INITIALIZING, States.DEAD]:
		health_bar.value = health
		stamina_bar.value = stamina
		evidence_bar.value = min(evidence, 100)
		#print("evidence: " + str(evidence))

		if State == States.DYING:
			dying_warning_label.visible = true
			var time_left = $Timers/DeathTimer.get_time_left()
			if time_left < 4.0:
				hud.show_dire_countdown(int(time_left))
			dying_warning_label.text = "You're dying, find bandages: " + str(int(time_left))
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
	
func update_item(currentItem, descriptive):
	if descriptive:
		quest_log.quests.append({"type": 'Clue: "', "quest": str(currentItem) , "status": '"'}) 
	else:
		quest_log.quests.append({"type": "Item: ", "quest": str(currentItem) , "status": " Picked Up"}) 
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
	weapon = gunScene
	loc.add_child(gunScene)
	
func upgrade_gun():
	var gunScene = weapon
	if gunScene.shot_num < 4:
		gunScene.shot_num += 1
	else:
		#After quadshot update bullet spped and decrease wait between shots
		gunScene.upgrader += 1
	
func begin_rocketization():
	weapon.rocketize()
	
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
		self_position = self.global_position
		if delta != 0:
			move(delta)
			rotate_melee_attack_zone(delta)
			set_primary_target_area(get_FOV_circle(Vector2(0,0),300))
			$Flashlight.look_at(get_global_mouse_position())
			point_gun()
			if stamina < 100 :
				stamina = min(stamina + stamina_recovery_rate * delta, max_stamina)
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
		



func change_health_bar(amount):
	$CanvasLayer/HUD.remove_boss_health(amount)




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
	set_state(States.DYING)
	if Global.user_preferences["gore"] == false:
			$BloodDripParticles.texture = null
	$AnimationPlayer.play("dying")
	
	dying_warning_label.visible = true
	$Timers/DyingWarningUpdateTimer.start()
	hud.show_blood_vignette()

func recover_from_near_death():
	# player found a bandage after dying process started.
	# Celebrate and give max_health
	hud.hide_blood_vignette()
	dying_warning_label.hide()
	set_state(States.READY)
	health = max_health
	$RecoveryNoise.set_pitch_scale(rand_range(0.9, 1.1))
	$RecoveryNoise.play()
	$RecoveryFireworks.emitting = true
	$BloodDripParticles.emitting = false
	update_bars()
	hud._on_player_recovered()

func die_for_real_this_time():
	dead = true
	set_state(States.DEAD)
	$DeathScream.play()
	$PaperDoll.hide()
	$deadPlaceholder.show()


func rotate_melee_attack_zone(_delta):
	$MeleeAttackZone.look_at(get_global_mouse_position())

func point_gun():
	if $PaperDoll.has_method("aim_toward"):
		$PaperDoll.aim_toward(get_global_mouse_position() - self.global_position)

func move(_delta):
	# delta not required for move_and_slide

	var speed = player_speed
	
	if Input.is_action_just_pressed("sprint") and get_state() != States.DASHING and stamina > min_dash_stamina_requirement:
		start_dash()
	elif Input.is_action_just_pressed("sprint") and get_state() != States.DASHING and stamina < min_dash_stamina_requirement:
		$DashAudio/InsufficientEnergySound.play()
		
	elif get_state() == States.DASHING and Input.is_action_pressed("sprint") and stamina > 0: # continue dashing
		speed *= dash_velocity_multiple
		stamina -= dash_stamina_cost
		update_bars()
	elif get_state() == States.DASHING: # no longer holding shift, revert back to walking
		revert_state()
	
	var move_vector = Vector2.ZERO
	var directional_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		#$PaperDoll/Lower.rotation_degrees = -90
		move_vector += Vector2.UP * speed
	if Input.is_action_pressed("ui_left"):
		#$PaperDoll.scale.x = -abs($PaperDoll.scale.x)
		#$PaperDoll/Lower.rotation_degrees = 180
		move_vector += Vector2.LEFT * speed
	if Input.is_action_pressed("ui_right"):
		#$PaperDoll.scale.x = abs($PaperDoll.scale.x)
		#$PaperDoll/Lower.rotation_degrees = 0
		move_vector += Vector2.RIGHT * speed
	if Input.is_action_pressed("ui_down"):
		#$PaperDoll/Lower.rotation_degrees = 90
		move_vector += Vector2.DOWN * speed
	directional_vector = move_vector

	var _collision = move_and_slide(directional_vector) # move and slide doesn't use delta.
	play_animations(directional_vector)
	last_movement_vector = directional_vector
	

func start_dash():
	set_state(States.DASHING)
	$PaperDoll.dash()
	$DashAudio/DashSound.play()
	
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
	
func _on_collectible_picked_up(pickupObj):
	print("pickupObj.item_info[item_name] == " + pickupObj.item_info["item_name"])
	if "Clue" in pickupObj.item_info["item_name"]:
		evidence += 1
		print("evidence == "+str(evidence))
		update_bars()

func _on_hit(damage : float = 10.0, impactVector : Vector2 = Vector2.ZERO):
	# play a noise, flash the sprite or queue animation, launch particles, start invulnerability timer
	# in some games, taking damage supercharges your adrenaline and you gain speed / damage
	if State == States.INITIALIZING:
		return
	elif not State in [States.INVULNERABLE, States.DASHING, States.DYING, States.DEAD]: 
		$HitNoise.play()
		if Global.user_preferences["gore"]:
			$AnimationPlayer.play("hit")
		health -= damage
		update_bars()
		knockback(impactVector.normalized() * damage)
		if health <= 0 and State != States.DYING:
			begin_dying()
		else:
			set_state(States.INVULNERABLE)
			$Timers/InvulnerbailityTimer.start()
		
func knockback(impactVector):
	var _collision = move_and_collide(impactVector)
	#position += impactVector
		
func _on_healed(amount):
	if health < max_health:
		health = min(health + amount, max_health)
		update_bars()
	if State == States.DYING:
		recover_from_near_death()


func _on_InvulnerbailityTimer_timeout():
	if health > 0:
		set_state(States.READY)
	
		
	
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
