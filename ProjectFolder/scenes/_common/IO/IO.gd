# placeholder script where we can set up saving and loading files


extends Node



var stored_items = [] # list of item names
var savegame_filepath = "user://save_game.tres"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.IO = self
	
	
func _on_collectible_picked_up(itemObj): # stored in Collectible as item_info. (src = res://scenes/_common/IO/InventoryItemResource.gd)
	# store it in inventory unless it's unique.
	var itemResource = itemObj.item_info
	
	if itemResource.is_unique == true:
		if not stored_items.has(itemResource):
			stored_items.push_back(itemResource) # store the reference to the object for later.. not useful for save/load unless we translate to resources or json
	else:
		stored_items.push_back(itemResource)


func get_inventory():
	return stored_items

func _on_collectible_used(usedItemName):
	for item in stored_items:
		if item.item_name.to_lower().strip_edges() == usedItemName.to_lower().strip_edges():
			stored_items.erase(item) # removes the first occurrence
			return
	
func has_item(itemNameQuery : String):
	var found = false
	for item in stored_items:
		if item.item_name.to_lower().strip_edges() == itemNameQuery.to_lower().strip_edges():
			found = true
	return found

func get_item(itemName : String) -> Resource: # Resources are simpler than objects, and are easily serialized to disk with ResourceSaver.save(path, resource)
	var itemResource = null
	for item in stored_items:
		if item.item_name.to_lower() == itemName.to_lower():
			itemResource = item
	return itemResource


func save_inventory():

	var save_game = Resource.new()
	save_game.set("stored_items", stored_items)
	var status = ResourceSaver.save(savegame_filepath, save_game, ResourceSaver.FLAG_BUNDLE_RESOURCES)
	if status != OK:
		printerr("problem in IO.gd, can't save game. error " + str(status))

func load_inventory():
	var restored_game : Resource
	if ResourceLoader.exists(savegame_filepath):
		restored_game = ResourceLoader.load(savegame_filepath)
		stored_items = restored_game.stored_items
		

