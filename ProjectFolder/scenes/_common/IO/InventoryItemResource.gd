class_name InventoryItemResource, "res://scenes/_common/GUI/icons/book.svg"

extends Resource

export var path_to_popup_display_image : String
export var path_to_icon : String
export var item_name : String
export var notes_for_journal : String
export var is_unique: bool = true # if not unique, inventory can hold more than one
export var display_immediately: bool = false
export var path_to_scene_for_PlayerController_Items: String # The scene

	
