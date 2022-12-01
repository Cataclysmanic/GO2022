extends AudioStreamPlayer2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var hornsPath = "res://scenes/City/2D_WorldMap/audio/CarHorns/"
	var filesArr = get_files(hornsPath)
	var randHorn = load(filesArr[randi()%filesArr.size()])
	self.set_stream(randHorn)
	
	
	
	
func get_files(dirPath) -> Array:
	var filesArr = []
	var dir = Directory.new()
	if dir.open(dirPath) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var count = 0
		var escape = 100
		while file_name != "" and count < escape:
			if dir.current_is_dir():
				pass
			else:
				var filetype = file_name.get_extension()
				if filetype == "ogg" or filetype == "wave": 
					filesArr.push_back(dirPath.plus_file(file_name))
			file_name = dir.get_next()
			count += 1
	return filesArr




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
