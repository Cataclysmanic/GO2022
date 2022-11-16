extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	find_node("GoreCheckButton").pressed = Global.user_preferences["gore"]
	find_node("ShakeNFlashButton").pressed = Global.user_preferences["shake_and_flash"]


func _on_DifficultySlider_drag_ended(_value_changed):
	Global.user_preferences["difficulty"] = find_node("DifficultySlider").value


func _on_GoreCheckButton_toggled(button_pressed):
	Global.user_preferences["gore"] = button_pressed


func _on_ShakeNFlashButton_toggled(button_pressed):
	Global.user_preferences["shake_and_flash"] = button_pressed
