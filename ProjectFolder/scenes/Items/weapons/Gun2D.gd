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
	$GunshotNoise.play()
	var myPos = get_global_position()
	var myRot = get_global_rotation()
	var bulletSpeed = 600.0
	var jitter = 8.0
	var jitterVec = Vector2(rand_range(-jitter, jitter), rand_range(-jitter, jitter))
	spawn_bullet(myPos+jitterVec, myRot, bulletSpeed)
	flash_muzzle()
	cock_gun()
	ammo_remaining -= 1
	emit_signal("player_gun_shot", ammo_remaining)


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
	bullet.init(pos, rot, speed)
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
	if State == States.READY:
		if ammo_remaining > 0:
			shoot()
		else:
			empty_click()
			
		
#func _on_magazine_received():  # HUD calls _on_hud_reloaded
#	reload(magazine_capacity)


func _on_CockTimer_timeout():
	State = States.READY
	$MuzzleFlash.visible = false
