

extends Button


export var SceneToLaunch : PackedScene
export var return_to_main : bool = false

var main_scene = "res://scenes/MenuScenes/MainMenu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_click_noise():
	var audioPlayer = find_node("AudioStreamPlayer")
	var randPitch = audioPlayer.get_pitch_scale() * rand_range(0.9, 1.1)
	audioPlayer.set_pitch_scale(randPitch) 
	audioPlayer.play()
	

func switch_scene():
	if SceneToLaunch != null:
		Global.world_controller.change_scene_to(SceneToLaunch)
	elif return_to_main == true:
		switch_to_main_scene()
	else:
		printerr("configuration error: SceneLaunchButton requires a SceneToLaunch (in the inspector)")

func switch_to_main_scene():
	Global.world_controller.change_scene(main_scene)


func _on_SceneLaunchButton_pressed():

	play_click_noise()



func _on_AudioStreamPlayer_finished():
	switch_scene()
	