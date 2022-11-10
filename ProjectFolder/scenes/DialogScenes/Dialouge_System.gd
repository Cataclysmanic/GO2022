extends CanvasLayer

export(Array, String) var dialouge_Text = []
export(AudioStream) var talking_audio
export var scene_to_change_to : PackedScene

var text_amount
var current_text

var still_dialouge = true

var main_scene = "res://scenes/MenuScenes/MainMenu.tscn"

func _ready():
	$AudioStreamPlayer.stream = talking_audio
	
	if dialouge_Text.size() != 0:
		text_amount = dialouge_Text.size()
		current_text = 0
		$Control/Label.text = dialouge_Text[0]
		$AudioStreamPlayer.playing = true
		

	
func _physics_process(delta):
	if still_dialouge == true:
		
		if Input.is_action_just_pressed("click"):
			if current_text < text_amount - 1:
				current_text += 1
				$Control/Label.text = dialouge_Text[current_text]
				$AudioStreamPlayer.playing = true
			else:
				still_dialouge = false
				$Fade_Player.play("Fade_out")
				


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.playing = false

func _on_Fade_Player_animation_finished(anim_name):
	print(scene_to_change_to)
	Global.world_controller.change_scene_to(scene_to_change_to)
