extends Node2D

signal picked_up(me)

func disappear():
	set_visible(false)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

func die():
	queue_free()

func _on_Area_body_entered(body):
	if body.has_method("is_player") and body.is_player() == true and body.health < 100:
		for i in 10:
			if body.health < 100:
				body.health += 1
				body.update_bars()
	#else say or show you already have enought heealt?

		emit_signal("picked_up", self)
		disappear()
		$PickupNoise.pitch_scale *= rand_range(0.9, 1.5)
		$PickupNoise.play()


func _on_PickupNoise_finished():
	die()
