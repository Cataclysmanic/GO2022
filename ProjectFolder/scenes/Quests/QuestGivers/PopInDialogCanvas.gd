tool
extends CanvasLayer


var dialogue_text = ["foo", "bar"]
var current_line = 0
var quest_giver

enum States { HIDDEN, TALKING }
var State = States.HIDDEN

signal finished()


# Called when the node enters the scene tree for the first time.
func _ready():
	quest_giver = get_parent()
	$Dialogue/PanelContainer/VBoxContainer/NameLabel.text = quest_giver.npc_name
	$Dialogue.hide()


func set_portrait(imageTex):
	var portraitNode = $Dialogue/PanelContainer/VBoxContainer/Portrait
	if portraitNode != null:
		portraitNode.set_texture(imageTex)

func popin():
	if Global.controller:
		$Dialogue/PanelContainer/VBoxContainer/NextButton.text = "Next"
	else:
		$Dialogue/PanelContainer/VBoxContainer/NextButton.text = "Next [F]"
	$Dialogue.show()
	$Dialogue/PanelContainer/VBoxContainer/NextButton.grab_focus()
	Global.pause()
	State = States.TALKING


func popout():
	$Dialogue.hide()
	Global.resume()
	State = States.HIDDEN
	if get_parent().has_method("_on_dialog_finished"):
		if not is_connected("finished", get_parent(), "_on_dialog_finished"):
			var _err = connect("finished", get_parent(), "_on_dialog_finished")
		emit_signal("finished")


func set_text(textArr):
	if textArr != null:
		dialogue_text = textArr
		$Dialogue/PanelContainer/VBoxContainer/DialogText.text = dialogue_text[0]

func advance_dialogue():
	current_line = min(current_line +1, dialogue_text.size()-1)
	$Dialogue/PanelContainer/VBoxContainer/DialogText.text = dialogue_text[current_line]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(_event):
	if Input.is_action_just_pressed("interact") and State == States.TALKING:
		advance_dialogue()
		

func _on_NextButton_pressed():
	advance_dialogue()


func _on_YesButton_pressed():
	if quest_giver.has_method("quest_accepted"):
		quest_giver.quest_accepted()
	popout()
	

func _on_NoButton_pressed():
	if quest_giver.has_method("quest_rejected"):
		quest_giver.quest_rejected()
	popout()
