extends HSlider


export var audio_bus_name := "Master"
export var audio_stream : AudioStream


func _ready() -> void:
	$AudioStreamPlayer.set_bus(audio_bus_name)
	value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(audio_bus_name)))
	$AudioStreamPlayer.set_stream(audio_stream)



func _on_VolumeSlider_drag_started():
	$AudioStreamPlayer.play()
	


func _on_VolumeSlider_drag_ended(value_changed):
	$AudioStreamPlayer.stop()


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), linear2db(value))
