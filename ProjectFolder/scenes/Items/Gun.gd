extends Spatial


var ammo = 6


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func shoot():
	if ammo > 0:
		$Bang.play()
		ammo -= 1
	else:
		$Click.play()

