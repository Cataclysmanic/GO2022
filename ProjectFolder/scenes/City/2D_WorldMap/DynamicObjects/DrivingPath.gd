extends Path2D

var max_cars = 10
var cars_on_road = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.start()


func spawn_car():
	cars_on_road += 1
	var carScene = $ResourcePreloader.get_resource("Car").instance()
	carScene.name = "Car_" + str(cars_on_road)
	var carPathFollow = $ResourcePreloader.get_resource("CarPathFollowTarget").instance()
	add_child(carPathFollow)
	carScene.init(carPathFollow)
	get_parent().add_child(carScene)

func _on_SpawnTimer_timeout():
	if cars_on_road <= max_cars:
		spawn_car()
		$SpawnTimer.set_wait_time(rand_range(4.0, 12.0))
		$SpawnTimer.start()
	
