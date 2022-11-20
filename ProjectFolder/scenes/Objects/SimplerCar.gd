extends PathFollow2D

var speed = 10.0
func _ready():
	pass

func _physics_process(delta):
	unit_offset += speed * delta
