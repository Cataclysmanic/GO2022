extends PathFollow2D

var speed = 25.0



# Called when the node enters the scene tree for the first time.
func _ready():
	set_unit_offset(randf())
	speed = rand_range(speed * 0.8, speed * 1.25)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_along_path(delta)


func move_along_path(delta):
	offset += speed * delta * get_speed_modifiers()
	

func get_speed_modifiers():
	var speedModifier = 1.0
	var potentialSpeedZones = $Area2D.get_overlapping_areas()
	for area in potentialSpeedZones:
		if "Hustle" in area.name:
			speedModifier = speedModifier * 1.5
		elif "Linger" in area.name:
			speedModifier = speedModifier * 0.667
	return speedModifier


func die():
	queue_free()

