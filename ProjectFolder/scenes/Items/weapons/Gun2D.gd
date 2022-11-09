extends Node2D

var ammo_remaining = 6
var map_scene

enum States { INITIALIZING, READY, EMPTY, FIRING, COCKING, EMPTY }
var State = States.INITIALIZING


signal projectile_ready(projectile)

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY

func init(mapScene):
	map_scene = mapScene
	var _err = connect("projectile_ready", map_scene, "_on_projectile_ready")
	
func reload():
	ammo_remaining = 6
	
func empty_click():
	$EmptyClickNoise.play()

func shoot():
	State = States.FIRING
	$GunshotNoise.play()
	var myPos = get_global_position()
	var myRot = get_global_rotation()
	var bulletSpeed = 600.0
	spawn_bullet(myPos, myRot, bulletSpeed)
	cock_gun()
		
func cock_gun():
	State = States.COCKING
	$CockTimer.start()


func spawn_bullet(pos, rot, speed):
	var bullet = $ResourcePreloader.get_resource("bullet").instance()
	bullet.init(pos, rot, speed)
	# note: bullets shouldn't be children of gun, or they'd track with the gun rotation
	# ask someone else to spawn the projectile.
	emit_signal("projectile_ready", bullet)


func _input(event):

	if event.is_action_pressed("shoot"):

		_on_trigger_pressed()
		
	
#func _unhandled_input(event):
#	if event.is_action_pressed("shoot"):
#
#		_on_trigger_pressed()
	

func _on_trigger_pressed():
	if State == States.READY:
		if ammo_remaining > 0:
			shoot()
		else:
			empty_click()
			
		
func _on_magazine_received():
	reload()


func _on_CockTimer_timeout():
	State = States.READY
