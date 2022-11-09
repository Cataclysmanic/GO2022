extends PanelContainer

export var next_scene = "res://scenes/MenuScenes/MainMenu.tscn"

export var intro_text = ""
export var outro_text = ""

export var audio : AudioStream
export var image_1 : Texture
export var image_2 : Texture
export var image_3 : Texture
export var image_4 : Texture
export var image_5 : Texture
var slide_images = []

onready var slide_container = find_node("TabContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	$FadeColorPanel.visible = true
	$FadeColorPanel.set_self_modulate(Color(0,0,0,1)) # opaque
	hide_tab_widgets()
	
	if intro_text != "":
		find_node("IntroText").text = intro_text
	if outro_text != "":
		find_node("OutroText").text = outro_text

	for image in [ image_1, image_2, image_3, image_4, image_5 ]:
		if image != null:
			slide_images.push_back(image)
		
	for i in range(len(slide_images)):
		var slideHolder = slide_container.find_node("Shot"+str(i))
		slideHolder.set_texture(slide_images[i])
	
	
	start_intro()
	
func start_intro():
	if audio != null:
		$BGMusic.set_stream(audio)
		$BGMusic.play()


	$TypingNoise.play()
	$AnimationPlayer.play("Start")
	
func hide_tab_widgets():
	var hiddenTabStyle = StyleBoxEmpty.new()
	slide_container.add_stylebox_override("tab_fg", hiddenTabStyle)
	slide_container.add_stylebox_override("tab_bg", hiddenTabStyle)
	for i in range(slide_container.get_child_count()):
		slide_container.set_tab_title(i, "")
	
	

func fade_out():
	$AnimationPlayer.play("FadeOut")

#	var tween = get_node("Tween")
#	tween.interpolate_property($FadeColorRect, "self_modulate",
#	Color(0,0,0,0), Color(0,0,0,1), 1,
#	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
	
func fade_in():
	$AnimationPlayer.play("FadeIn")

#	var tween = get_node("Tween")
#	tween.interpolate_property($FadeColorRect, "self_modulate",
#			Color(1.0,1.0,1.0,1.0), Color(0,0,0,0), ,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
	

	
	
func show_slide():
	fade_in()
	$Timer.start()
	
	
func _unhandled_input(event): # cardinal sin to not allow skipping cutscenes.
	if event.is_action_pressed("ui_cancel"):
		Global.world_controller.change_scene(next_scene)


func finish():
	$AnimationPlayer.play("Finish") # Outro text
	yield(get_tree().create_timer(1.0), "timeout")
	$TypingNoise.play()
	
func _on_Timer_timeout():
	$AnimationPlayer.play("FadeOut")
	
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		$TypingNoise.stop()
		$Timer.start()
		
	elif anim_name == "FadeOut":
		var currentTab = slide_container.current_tab
		currentTab += 1
		if currentTab == len(slide_images):
			finish() # last slide
		else:
			slide_container.current_tab = currentTab
			show_slide()
			
	elif anim_name == "Finish":
		$TypingNoise.stop()
		Global.world_controller.change_scene(next_scene)

