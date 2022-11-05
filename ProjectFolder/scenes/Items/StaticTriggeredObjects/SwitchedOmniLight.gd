extends OmniLight


export var turned_on : bool = false
export var myEnergy : float = 1.0
export var myRange : float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	light_energy = myEnergy
	omni_range = myRange


	if turned_on: 
		light_energy = 1
	else:
		light_energy = 0
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func flip_lightswitch():	
	turned_on = !turned_on
	$ClickNoise.play()
	if turned_on:
		light_energy = 1
	else:
		light_energy = 0

func _on_LightSwitch_body_entered(body):
	if "Detective" in body.name:
		flip_lightswitch()
		$LightSwitch/Sprite3D.hide()
