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
		var _status = get_tree().change_scene("res://GUI/MainMenu.tscn")
		# plex - how is this supposed to work? This scene won't be valid to switch to itself.
	

