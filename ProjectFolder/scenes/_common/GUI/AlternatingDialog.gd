extends CanvasLayer

enum scene_types { cutscene, level, final }
export (scene_types) var scene_type = scene_types.cutscene

var callback_scene
export var fallback_scene_if_no_callback : String = "res://scenes/MenuScenes/MainMenu.tscn"


onready var dialog_container = find_node("DialogContainer")
export var dialog : Array = []

onready var next_button = find_node("NextPageButton")
#export var exit_scene_name : String
#cutscenes always go back to the scene they were loaded from

var text_revealed : int = -1

var current_tab_num : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():

	instantiate_tabs()
	next_button.hide()

	$MusicLeadTimer.start()

func init(callbackScene):
	if callbackScene != null and is_instance_valid(callbackScene):
		callback_scene = callbackScene
	

func instantiate_tabs():
	for i in range(dialog.size()):
		var new_panel = Label.new()
		new_panel.set_text(dialog[i])
		new_panel.set_visible_characters(0)
		new_panel.set_autowrap(true)
		if i%2 == 0:
			new_panel.set_align(Label.ALIGN_RIGHT)
		else:
			new_panel.set_align(Label.ALIGN_LEFT)
		dialog_container.add_child(new_panel)


func start():

#	if exit_scene_name == null:
#		exit_scene_name = "res://Levels/HQ1.tscn"

#	if dialog.size() == 0:
#		dialog = [
#			"........"
#		]

	dialog_container.set_current_tab(0)
	next_button.show()
	next_tab()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func next_tab():



	text_revealed = -1
	current_tab_num += 1
	#var next_tab = dialog_container.get_current_tab()+1
	if current_tab_num == dialog.size():
		end_scene()
	else:
		dialog_container.set_current_tab(current_tab_num)
		reveal_letter()

		$TextRevealTimer.start()
		if current_tab_num%2 == 0:
			$TextRevealNoiseRight.play()
		else:
			$TextRevealNoiseLeft.play()

func end_scene():
	$TextRevealTimer.stop()

	if scene_type == scene_types.cutscene:
		 
		if callback_scene == null or is_instance_valid(callback_scene) == false:
			switch_to_fallback_scene()
		elif callback_scene.has_method("cutscene_finished"): # Ask it to free this scene
			var _err = connect("cutscene_finished", callback_scene, "_on_cutscene_finished")
			emit_signal("cutscene_finished")
	elif scene_type == scene_types.final:
		switch_to_fallback_scene()
	elif scene_type == scene_types.level:
		printerr("Incomplete code in AlternatingDialog. end_level requested, but we don't know what to do yet.")


#warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		advance_story()
	elif Input.is_action_just_pressed("ui_cancel"):
		end_scene()

func _on_NextPageButton_pressed():
	advance_story()

func advance_story():
	if dialog_container != null and is_instance_valid(dialog_container):
		var showing = dialog_container.get_child(current_tab_num).get_visible_characters()
		var length = dialog_container.get_child(current_tab_num).get_text().length()
		if showing < length:
			reveal_all_letters()
		else:
			next_tab()
		play_click_noise()


func switch_to_fallback_scene():
	var _status = Global.world_controller.change_scene(fallback_scene_if_no_callback)


func play_click_noise():
	pass
	
func play_hover_noise():
	pass

func reveal_all_letters():
	if dialog_container != null and is_instance_valid(dialog_container):
		text_revealed = dialog_container.get_child(current_tab_num).get_text().length()
		stop_mumbling()

func stop_mumbling():
	$TextRevealNoiseLeft.stop()
	$TextRevealNoiseRight.stop()


func reveal_letter():
	if dialog_container != null and is_instance_valid(dialog_container):
		text_revealed += 1
		dialog_container.get_child(current_tab_num).set_visible_characters(text_revealed)
		if text_revealed >= dialog_container.get_child(current_tab_num).get_text().length():
			$TextRevealNoiseLeft.stop()
			$TextRevealNoiseRight.stop()

func _on_TextRevealTimer_timeout():
	if dialog_container != null and is_instance_valid(dialog_container):
		reveal_letter()
		$TextRevealTimer.start()

func _on_AnyButton_hover():
	play_hover_noise()



func _on_MusicLeadTimer_timeout():
	start()
