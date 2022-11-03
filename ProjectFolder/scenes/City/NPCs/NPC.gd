extends KinematicBody

func _process(delta):
	if Global.topdown:
		$Sprite3D.animation = "tidle"
	else:
		$Sprite3D.animation = "widle"
