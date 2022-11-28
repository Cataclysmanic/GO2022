
#Main should be kept alive so it can instantiate and remove scenes

extends Control

onready var scene_container = find_node("SceneContainer")
var current_scene

enum STATES { INITIALIZING, ACTIVE, PAUSED }
var State = STATES.INITIALIZING

func _ready():
	randomize()
	Global.world_controller = self
	start_intro()
	State = STATES.ACTIVE
	Global.resume()
	

func start_intro():
	var splashScreen = $ResourcePreloader.get_resource("Intro")
	change_scene_to(splashScreen)
	
	

func change_scene_to(packedScene : PackedScene):
	remove_old_scenes()
	spawn_new_scene(packedScene)


func get_io():
	return find_node("IO")


func change_scene(scenePath : String):
	var newScene
	if ResourceLoader.exists(scenePath):
		remove_old_scenes()
		var packedScene = load(scenePath)
		newScene = spawn_new_scene(packedScene)
	else:
		printerr(str(self) + " " + self.name + " configuration error, scene file does not exist: Main.change_scene_to("+scenePath+")")
	return newScene

func remove_old_scenes():
	for scene in scene_container.get_children():
		if scene.has_method("die"):
			scene.die()
		else:
			scene.hide()
			scene.call_deferred("queue_free")


func spawn_new_scene(packedScene : PackedScene):
	var fade = $ResourcePreloader.get_resource("Fade").instance()

	scene_container.add_child(fade)
	yield(get_tree().create_timer(0.25), "timeout")

	var sceneObj = packedScene.instance()
	scene_container.add_child(sceneObj)
	current_scene = sceneObj
	#return sceneObj
	
	
func _on_cutscene_finished(cutsceneName):
	if cutsceneName == "Intro":
		var mainMenu = $ResourcePreloader.get_resource("MainMenu")
		change_scene_to(mainMenu)
	elif cutsceneName == "Brother":
		change_scene("res://scenes/City/2D_WorldMap/2D_CItyMap.tscn")
	else:
		change_scene("res://GUI/MainMenu.tscn")
		

func _on_ending_requested():
	# next scene will get the ending name from Global.chosen_ending
	var basePath = "res://scenes/CutScenes/Animatics/Scene 4/EndingAnimatic_"
	if Global.chosen_ending == "GetOutOfJailCard":
		change_scene(basePath+"GetOutOfJailCard.tscn")
	elif Global.chosen_ending == "GoToJail":
		change_scene(basePath+"GoToJail.tscn")
	elif Global.chosen_ending == "CollectedEvidence":
		change_scene(basePath+"CollectedEvidence.tscn")
	elif Global.chosen_ending == "BeatTheBoss":
		change_scene(basePath+"BeatTheBoss.tscn")
	Global.resume() # When the player collects an item, it pops up and the game pauses... paused game means animations won't play. So resume!!!
	
