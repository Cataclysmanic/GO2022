extends TextureButton


var safe_icons = ["book", "flashlight", "gun", "paper"]
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

	if safe_icons.has(itemRes.item_name.to_lower()):
			
		texture_normal = load(icon_path.plus_file(itemRes.item_name)+"-n.png")
		texture_pressed = load(icon_path.plus_file(itemRes.item_name)+"-c.png")
		texture_hover = load(icon_path.plus_file(itemRes.item_name)+"-h.png")

		Global.Utils.safe_connect(self, "inventory_icon_clicked", hud)
	



func _on_InventoryIconButton_pressed():
	emit_signal("inventory_icon_clicked", item_resource)
