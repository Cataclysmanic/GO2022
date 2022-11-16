extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_DifficultySlider_drag_ended(value_changed):
	Global.difficulty = find_node("DifficultySlider").value
