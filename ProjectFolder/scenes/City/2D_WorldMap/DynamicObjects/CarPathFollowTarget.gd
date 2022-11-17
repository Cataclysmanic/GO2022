extends PathFollow2D


var speed = 200.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_offset(get_offset() + speed * delta)

func speed_up():
	speed += 0.1
	
func slow_down():
	speed = max(speed - 0.1, 0 )
	
