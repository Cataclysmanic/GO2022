

extends Button


export var SceneToLaunch : PackedScene
export var return_to_main : bool = false

var main_scene = "res://scenes/MenuScenes/MainMenu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.grab_focus()
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("ui_quit"):
		switch_scene()

func play_click_noise():
	var audioPlayer = find_node("ClickSound")
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
	if Global.world_controller == null:
		return
	else:
		Global.world_controller.change_scene(main_scene)


func _on_SceneLaunchButton_pressed():

	play_click_noise()



	


func _on_ClickSound_finished():
	switch_scene()

func _on_SceneLaunchButton_mouse_entered():
	if not disabled:
		$HoverSound.play()
	else:
		$DisabledSound.play()
		
