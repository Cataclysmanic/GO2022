
#Main should be kept alive so it can instantiate and remove scenes


extends Control

onready var scene_container = find_node("SceneContainer")
var current_scene

enum STATES { INITIALIZING, ACTIVE, PAUSED }
var State = STATES.INITIALIZING

func _ready():
	Global.world_controller = self
	start_intro()
	State = STATES.ACTIVE


func start_intro():
	var splashScreen = $ResourcePreloader.get_resource("Intro")
	change_scene_to(splashScreen)
	
	

func change_scene_to(packedScene : PackedScene):
	remove_old_scenes()
	spawn_new_scene(packedScene)


func change_scene(scenePath : String):
	if ResourceLoader.exists(scenePath):
		remove_old_scenes()
		var packedScene = load(scenePath)
		spawn_new_scene(packedScene)
	else:
		printerr("configuration error, scene file does not exist: Main.change_scene_to("+scenePath+")")


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

	
	
func _on_cutscene_finished(cutsceneName):
	if cutsceneName == "Intro":
		var mainMenu = $ResourcePreloader.get_resource("MainMenu")
		change_scene_to(mainMenu)
	else:
		change_scene("res://GUI/MainMenu.tscn")
		

