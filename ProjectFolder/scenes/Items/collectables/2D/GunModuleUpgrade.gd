extends Node2D

enum States { READY, DISABLED }
var State = States.READY

signal picked_up(me)

func disappear():
	set_visible(false)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

func die():
	State = States.DISABLED
	call_deferred("queue_free")

func _on_Area_body_entered(body):
	if State == States.DISABLED:
		return
		
	if body.has_method("is_player") and body.is_player() == true:
		if body.has_method("upgrade_gun"):
			body.upgrade_gun()
			body.update_item("GUN UPGRADE", false)

		emit_signal("picked_up", self)
		disappear()
		$PickupNoise.pitch_scale *= rand_range(0.9, 1.5)
		$PickupNoise.play()

func disable_pickup():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	State = States.DISABLED
	
	
func enable_pickup():
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	State = States.READY	


func _on_PickupNoise_finished():
	die()
