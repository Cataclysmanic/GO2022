extends Container


#signal finished(sceneName)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_Timer_timeout():
	#connect("finished", Global.world_controller, "_on_cutscene_finished")
	find_node("AnimationPlayer").play("FadeCutscene")


func finish():
	get_tree().quit()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeCutscene":
		finish()
	
