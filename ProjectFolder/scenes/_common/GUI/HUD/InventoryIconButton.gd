extends TextureButton


#var safe_icons = ["book", "flashlight", "gun", "paper"]
var safe_icons = []
var HUD
var item_resource

signal inventory_icon_clicked(name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init(itemRes, hud):
	HUD = hud
	item_resource = itemRes

	#build_safe_icon_list() # hare-brained idea in the first place
	setup_textures(itemRes)

	var _err = connect("inventory_icon_clicked", hud, "_on_inventory_icon_clicked")

		#Global.Utils.safe_connect(self, "inventory_icon_clicked", hud)

func setup_textures(itemRes):
	var baseIconPath = itemRes.path_to_icon.trim_suffix("-n.png")
	if ResourceLoader.exists(itemRes.path_to_icon):
		texture_normal = load(itemRes.path_to_icon)
	if ResourceLoader.exists(baseIconPath + "-c.png"):
		texture_pressed = load(baseIconPath + "-c.png")
	if ResourceLoader.exists(baseIconPath + "-h.png"):
		texture_pressed = load(baseIconPath + "-h.png")
	
#	if safe_icons.has(itemRes.item_name.to_lower()):
#		var icon_path = 'res://scenes/_common/GUI/icons'
#		texture_normal = load(icon_path.plus_file(itemRes.item_name)+"-n.png")
#		texture_pressed = load(icon_path.plus_file(itemRes.item_name)+"-c.png")
#		texture_hover = load(icon_path.plus_file(itemRes.item_name)+"-h.png")


#func build_safe_icon_list():
#	# just a complicated way to say, did someone make this icon yet?
#
#	# walk the directory and find all things ending in -c.png
#	var path = "res://scenes/_common/GUI/icons/"
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		var count = 0
#		var escape_threshold = 100
#		while file_name != "" and count < escape_threshold: # end of directory, no files left when file_name == ""
#			if not dir.current_is_dir():
#				if file_name.ends_with("-n.png"):
#					safe_icons.push_back(file_name.trim_suffix("-n.png"))
#			file_name = dir.get_next()
#			count += 1
#	#print(safe_icons)



func _on_InventoryIconButton_pressed():
	
	emit_signal("inventory_icon_clicked", item_resource) # --> HUD
