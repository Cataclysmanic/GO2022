extends PathFollow2D


var speed = 500.0
var max_speed = 900.0
var min_speed = 10.0
var acceleration = 100.0

enum States { INITIALIZING, READY, MOVING, STOPPED }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State in [States.READY, States.MOVING]:
		set_offset(get_offset() + (speed * delta))


func die():
	call_deferred("queue_free")

func speed_up(_delta):
	#speed = min( speed + (acceleration * delta), max_speed)
	speed = max_speed
	
func slow_down(_delta):
	speed = max(speed - (acceleration*_delta), min_speed )

func stop():
	State = States.STOPPED
	set_v_offset(200.0)
	
