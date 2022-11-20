extends PathFollow2D

var speed = .001
func _ready():
	pass

func _physics_process(delta):
	unit_offset += speed
