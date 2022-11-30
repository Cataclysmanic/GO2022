extends Node2D

var ammo_remaining = 0
var magazine_capacity = 12
var map_scene
var player
var camera
var HUD

enum States { INITIALIZING, READY, EMPTY, FIRING, COCKING, EMPTY }
var State = States.INITIALIZING
var launcher = preload("res://scenes/Player/PaperDoll/rocketlauncher-topdown.png")

signal projectile_ready(projectile)
signal player_gun_shot(ammoRemaining)
signal player_gun_loaded(ammoRemaining, ammoType)
signal player_gun_reload_requested()
signal loud_noise(location)

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY
	if Global.rockets:
		rocketize()
	
func init(mapScene, myPlayer, hud):
	player = myPlayer
	
	map_scene = mapScene
	HUD = hud
	camera = player.camera

	var _err
	if map_scene != null and is_instance_valid(map_scene):
		_err = connect("projectile_ready", map_scene, "_on_projectile_ready")
	if hud != null and is_instance_valid(hud):
		_err = connect("player_gun_shot", hud, "_on_player_gun_shot")
		_err = connect("player_gun_loaded", hud, "_on_player_gun_loaded")
		_err = connect("player_gun_reload_requested", hud, "_on_player_gun_reload_requested")
	
	if map_scene != null and is_instance_valid(map_scene) and map_scene.has_method("_on_loud_noise_made"):
		_err = connect("loud_noise", map_scene, "_on_loud_noise_made")
	reload(magazine_capacity)
	
func rocketize():
	Global.rockets = true
	$Sprite.texture = launcher
	$Sprite.visible = true
	$Sprite.scale.x = 3
	$Sprite.scale.y = 3
	
func reload(num):
	if num == null or num == 0:
		ammo_remaining = magazine_capacity
	else:
		ammo_remaining += num
	emit_signal("player_gun_loaded", ammo_remaining, "22 cal")
	
func empty_click():
	$EmptyClickNoise.play()
	emit_signal("player_gun_reload_requested", self)

func shoot():
	State = States.FIRING
	make_gunshot_noise()
	$CockTimer.wait_time = max(0.4 - 0.05 * Global.upgrader, 0.001)
	var myPos = get_global_position()
	var myRot = get_global_rotation()
	var bulletSpeed = 1000+100*Global.upgrader
	if Global.rockets:
		bulletSpeed = 800
	var jitter = 8.0
	var jitterVec = Vector2(rand_range(-jitter, jitter), rand_range(-jitter, jitter))
	if Global.shot_num == 1:
		spawn_bullet(myPos+jitterVec, myRot, bulletSpeed)
	if Global.shot_num == 2:
		spawn_bullet(myPos+2*jitterVec, myRot, bulletSpeed)
		spawn_bullet(myPos-2*jitterVec, myRot, bulletSpeed)
	if Global.shot_num == 3:
		spawn_bullet(myPos+jitterVec, myRot, bulletSpeed)
		spawn_bullet(myPos+jitterVec, myRot+50, bulletSpeed)
		spawn_bullet(myPos+jitterVec, myRot-50, bulletSpeed)
	if Global.shot_num >= 4:
		spawn_bullet(myPos+2*jitterVec, myRot, bulletSpeed)
		spawn_bullet(myPos-2*jitterVec, myRot, bulletSpeed)
		spawn_bullet(myPos+jitterVec, myRot+50, bulletSpeed)
		spawn_bullet(myPos+jitterVec, myRot-50, bulletSpeed)
	if !Global.rockets:
		if Global.user_preferences["shake_and_flash"] == true:
			eject_casing()
	if Global.user_preferences["shake_and_flash"] == true:
		flash_muzzle()
		knockback_shooter(Vector2.RIGHT.rotated(myRot))
	cock_gun()
	ammo_remaining -= 1
	emit_signal("player_gun_shot", ammo_remaining)
	emit_signal("loud_noise", get_global_position())

func make_gunshot_noise():
	var audio_effects_enabled = false
	var audioBusIdx = AudioServer.get_bus_index("Gunshots")
	var delayIdx = 0
	var distortionIdx = 1
	var delay = AudioServer.get_bus_effect(audioBusIdx, delayIdx) # see Class: AudioEffectDelay
	var distortion = AudioServer.get_bus_effect(audioBusIdx, distortionIdx) # see Class: AudioEffectDistortion
	
	delay.set_dry(rand_range(0.0, 0.02))	
	delay.set_tap1_active(true) 
	delay.set_tap1_delay_ms(rand_range(0, 75))
	delay.set_tap1_level_db(rand_range(0.0, 10.0))
	delay.set_tap2_active(false)

	distortion.set_drive(rand_range(0.0, 0.03))

	AudioServer.set_bus_effect_enabled(audioBusIdx, delayIdx, audio_effects_enabled) 
	AudioServer.set_bus_effect_enabled(audioBusIdx, distortionIdx, audio_effects_enabled)

	var gunshotNoise = $GunshotNoises.get_children()[randi()%$GunshotNoises.get_child_count()]
	gunshotNoise.set_pitch_scale(rand_range(0.98, 1.02))
	if Global.rockets:
		gunshotNoise.set_pitch_scale(0.3)
	#gunshotNoise.set_volume_db(rand_range(-4.0, -4.0))
	gunshotNoise.set_volume_db(-2.0)
	
	gunshotNoise.play()	
	

func eject_casing():
	
	var casing = $ResourcePreloader.get_resource("casing").instance()
	casing.rotation = rand_range(-PI, PI)
	casing.set_global_position(get_global_position())
	emit_signal("projectile_ready", casing)


func knockback_shooter(impactVector):
	var magnitude = 10.0
	if Global.rockets:
		magnitude += 10
	player.position -= impactVector.normalized()*magnitude


func flash_muzzle():
	if Global.user_preferences["shake_and_flash"]:
		var flash = $MuzzleFlash
		flash.rotation = rand_range(-0.2, 0.2)
		flash.visible = true
		var tween = get_node("Tween")
		tween.interpolate_property(flash, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), .2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		if camera != null and camera.has_method("shake"):
			camera.shake()
	
	
		
func cock_gun():
	State = States.COCKING
	$CockTimer.start()


func spawn_bullet(pos, rot, speed):
	var bullet = $ResourcePreloader.get_resource("bullet").instance()
	bullet.init(self, pos, rot, speed)
	# note: bullets shouldn't be children of gun, or they'd track with the gun rotation
	# ask someone else to spawn the projectile.
	emit_signal("projectile_ready", bullet)


#func _input(event):
#
#	if event.is_action_pressed("shoot"):
#
#		_on_trigger_pressed()

func _on_HUD_reloaded(numAmmo):
	reload(numAmmo)

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		_on_trigger_pressed()


func _on_trigger_pressed():
	if State == States.READY and player.State != player.States.DEAD:
		if ammo_remaining > 0:
			shoot()
		else:
			empty_click()
			
		
#func _on_magazine_received():  # HUD calls _on_hud_reloaded
#	reload(magazine_capacity)


func _on_CockTimer_timeout():
	State = States.READY
	$MuzzleFlash.visible = false
