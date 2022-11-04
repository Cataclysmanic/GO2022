extends AudioStreamPlayer


export var audio_1 : AudioStream
export var audio_2 : AudioStream
export var audio_3 : AudioStream



# Called when the node enters the scene tree for the first time.
func _ready():
	var streams = []
	for stream in [audio_1, audio_2, audio_3]:
		if stream != null:
			streams.push_back(stream)
	
	if len(streams)>0:
		set_stream(streams[randi()%len(streams)])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
