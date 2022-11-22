extends Node2D


signal noise(location)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("make noise")
	#notify_nearby_npcs()


func notify_nearby_npcs():
	var NPCs = $Area2D.get_overlapping_bodies()
	for NPC in NPCs:
		if NPC.has_method("_on_noise_nearby"):
			var _err = connect("noise", NPC, "_on_noise_nearby")
	emit_signal("noise", get_global_position())

func die():
	call_deferred("queue_free")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "make noise":
		die()


func _on_Area2D_body_entered(body):
	if body.has_method("_on_noise_nearby"):
		body._on_noise_nearby(get_global_position())
