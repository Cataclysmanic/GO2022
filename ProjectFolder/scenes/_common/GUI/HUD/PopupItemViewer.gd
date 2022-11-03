extends PopupPanel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(itemName : String, pathToImage : String):
	find_node("ItemName").text = itemName
	var imageTex = load(pathToImage)
	if imageTex:
		find_node("ItemImage").texture = imageTex
	popup_centered_ratio(0.667)
	$Timer.start()
	

func _on_Timer_timeout():
	hide()


func _on_OKButton_pressed():
	hide()
