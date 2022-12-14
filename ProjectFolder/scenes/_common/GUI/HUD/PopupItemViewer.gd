extends PopupPanel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(itemResource : InventoryItemResource):
	assert(itemResource != null)
	Global.pause()
	find_node("ItemName").text = itemResource.item_name
	find_node("ItemDescription").text = itemResource.notes_for_journal
	var imageTex = load(itemResource.path_to_popup_display_image)
	if imageTex:
		find_node("ItemImage").texture = imageTex
	popup_centered_ratio(0.667)
	$Timer.start()

func _unhandled_input(event):
	if not is_visible_in_tree():
		return
	
	elif (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_select")
		or event.is_action_pressed("ui_cancel")
	):
		resume()

	
func _on_Timer_timeout():
	resume()

		
func resume():
	$Timer.stop()
	Global.resume()
	hide()
	
	
func _on_OKButton_pressed():
	resume()	







func _on_PopupItemViewer_popup_hide():
	pass
	#Global.resume()

