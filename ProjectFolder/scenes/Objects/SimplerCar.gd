extends PathFollow2D

var speed = 0.1
func _ready():
	pass

func _physics_process(delta):
	unit_offset += speed * delta * Global.game_speed
