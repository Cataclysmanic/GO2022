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
	var icon_path = 'res://scenes/_common/GUI/icons'
	build_safe_icon_list()

	if safe_icons.has(itemRes.item_name.to_lower()):
			
		texture_normal = load(icon_path.plus_file(itemRes.item_name)+"-n.png")
		texture_pressed = load(icon_path.plus_file(itemRes.item_name)+"-c.png")
		texture_hover = load(icon_path.plus_file(itemRes.item_name)+"-h.png")

		Global.Utils.safe_connect(self, "inventory_icon_clicked", hud)


func build_safe_icon_list():
	# just a complicated way to say, did someone make this icon yet?

	# walk the directory and find all things ending in -c.png
	var path = "res://scenes/_common/GUI/icons/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var count = 0
		var escape_threshold = 100
		while file_name != "" and count < escape_threshold: # end of directory, no files left when file_name == ""
			if not dir.current_is_dir():
				if file_name.ends_with("-n.png"):
					safe_icons.push_back(file_name.trim_suffix("-n.png"))
			file_name = dir.get_next()
			count += 1



func _on_InventoryIconButton_pressed():
	emit_signal("inventory_icon_clicked", item_resource)
