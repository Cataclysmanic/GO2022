extends KinematicBody2D

var health = 20.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func flash_hit():
	$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	$DieNoise.play()
	$AnimationPlayer.play("die")
	$CollisionShape2D.call_deferred("set_disabled", true)
	

func _on_hit(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_hit()
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		set_visible(false)
		queue_free()
