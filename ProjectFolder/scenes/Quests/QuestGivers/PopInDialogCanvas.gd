tool
extends CanvasLayer


var dialogue_text = ["foo", "bar"]
var current_line = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Dialogue.hide()


func set_portrait(imageTex):
	var portraitNode = $Dialogue/PanelContainer/VBoxContainer/Portrait
	if portraitNode != null:
		portraitNode.set_texture(imageTex)

func popin():
	$Dialogue.show()
	Global.pause()


func popout():
	$Dialogue.hide()
	Global.resume()

func set_text(textArr):
	if textArr != null:
		dialogue_text = textArr
		$Dialogue/PanelContainer/VBoxContainer/DialogText.text = dialogue_text[0]

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
