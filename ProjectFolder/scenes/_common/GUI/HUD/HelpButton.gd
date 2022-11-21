extends Button



onready var quest_log = find_node("QuestLog")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func toggle_journal():
	if $PlayerInstructions.visible == true:
		$PlayerInstructions.hide()
		Global.resume()
	else:
		$PlayerInstructions.popup_centered_ratio(0.75)
		# signal "about_to_show" handles this
		#$PlayerInstructions/QuestLog.populate_questlog()
		Global.pause()

func _unhandled_input(event):
	if $PlayerInstructions.visible: # many keys to close
		var actions = ["open_journal", "ui_accept", "ui_cancel", "ui_select"]
		for action in actions:
			if event.is_action_pressed(action):
				toggle_journal()
	else: # only J or button to open
		if event.is_action_pressed("open_journal"):
			toggle_journal()


#func _on_HelpButton_pressed():
#	toggle_journal()


func _on_HelpButton_toggled(_button_pressed):
	toggle_journal()


func _on_PlayerInstructions_about_to_show():
	quest_log.populate_questlog()


func _on_PlayerInstructions_popup_hide():
	quest_log.erase_visible_questlog()
	Global.resume()
	


func _on_CloseButton_pressed():
	toggle_journal()
