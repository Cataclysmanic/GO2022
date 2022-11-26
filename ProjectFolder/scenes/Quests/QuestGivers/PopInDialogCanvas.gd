extends CanvasLayer


var dialogue_text = ["foo", "bar"]
var current_line = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Dialogue.hide()


func popin():
	$Dialogue.show()
	Global.pause()


func popout():
	$Dialogue.hide()
	Global.resume()

func set_dialogue_text(textArr):
	if textArr != null:
		dialogue_text = textArr

func advance_dialogue():
	current_line += 1
	$Dialogue/PanelContainer/VBoxContainer/DialogText.text = dialogue_text[current_line%dialogue_text.size()]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NextButton_pressed():
	advance_dialogue()


func _on_YesButton_pressed():
	popout()
	

func _on_NoButton_pressed():
	popout()
