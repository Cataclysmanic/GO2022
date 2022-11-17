extends Node2D

var ammo_remaining = 0
var magazine_capacity = 12
var map_scene
var player
var camera
var HUD

enum States { INITIALIZING, READY, EMPTY, FIRING, COCKING, EMPTY }
var State = States.INITIALIZING


signal projectile_ready(projectile)
signal player_gun_shot(ammoRemaining)
signal player_gun_loaded(ammoRemaining, ammoType)
signal player_gun_reload_requested()


# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY

func init(mapScene, myPlayer, hud):
	player = myPlayer
	map_scene = mapScene
	HUD = hud
	camera = player.camera

	var _err = connect("projectile_ready", map_scene, "_on_projectile_ready")
	_err = connect("player_gun_shot", hud, "_on_player_gun_shot")
	_err = connect("player_gun_loaded", hud, "_on_player_gun_loaded")
	_err = connect("player_gun_reload_requested", hud, "_on_player_gun_reload_requested")
	reload(magazine_capacity)
	
	
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
	var audioBusIdx = AudioServer.get_bus_index("Gunshots")
	var delayIdx = 0
	var distortionIdx = 1
	var delay = AudioServer.get_bus_effect(audioBusIdx, delayIdx) # see Class: AudioEffectDelay
	var distortion = AudioServer.get_bus_effect(audioBusIdx, distortionIdx) # see Class: AudioEffectDistortion
	#delay.set_dry(rand_range(0.0, 0.02))
	
	delay.set_tap1_active(true) 
	delay.set_tap1_delay_ms(rand_range(0, 75))
	delay.set_tap1_level_db(rand_range(0.0, 10.0))
	delay.set_tap2_active(false)
	#distortion.set_drive(rand_range(0.0, 0.03))

	AudioServer.set_bus_effect_enabled(audioBusIdx, delayIdx, false) # change this to true if you want reverb
	AudioServer.set_bus_effect_enabled(audioBusIdx, distortionIdx, false)#  change this to true if you want distortion

	var gunshotNoise = $GunshotNoises.get_children()[randi()%$GunshotNoises.get_child_count()]
	gunshotNoise.set_pitch_scale(rand_range(0.98, 1.02))
	#gunshotNoise.set_volume_db(rand_range(-4.0, -4.0))
	gunshotNoise.set_volume_db(-4.0)
	
	gunshotNoise.play()
	var myPos = get_global_position()
	var myRot = get_global_rotation()
	var bulletSpeed = 1000.0
	var jitter = 8.0
	var jitterVec = Vector2(rand_range(-jitter, jitter), rand_range(-jitter, jitter))
	spawn_bullet(myPos+jitterVec, myRot, bulletSpeed)
	eject_casing()
	flash_muzzle()
	knockback_shooter(Vector2.RIGHT.rotated(myRot))
	cock_gun()
	ammo_remaining -= 1
	emit_signal("player_gun_shot", ammo_remaining)


func eject_casing():
	var casing = $ResourcePreloader.get_resource("casing").instance()
	casing.rotation = rand_range(-PI, PI)
	casing.set_global_position(get_global_position())
	emit_signal("projectile_ready", casing)


func knockback_shooter(impactVector):
	var magnitude = 10.0
	player.position -= impactVector.normalized()*magnitude


func flash_muzzle():
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
