extends Control


var current_scene

func _ready():
	Global.world_controller = self
	$MainMenu.hide()
	$IntroCutscene.show()
	
	
func _on_cutscene_finished(cutsceneName):
	if cutsceneName == "Intro":
		$IntroCutscene.hide()
		$MainMenu.show()
	else:
		get_tree().change_scene("res://GUI/MainMenu.tscn")
	
