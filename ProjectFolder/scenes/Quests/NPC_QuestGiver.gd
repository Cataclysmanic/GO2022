# Should be able to:

# interact with the player
	# spawn dialog
# ask the city for a random quest target location
# produce a quest object from ResourcePreloader
# ask the city to spawn the quest object at the location

# tell the player what to do.
# maybe ask the HUD to produce a collectible journal item.. note, paper, etc.

# move around a bit? Maybe not necessary
# if it can move around, we could set up escort quests (the worst of all possible quests)



extends KinematicBody2D


var city_map
var quest_target_location

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide()

func init(cityMap):
	city_map = cityMap

func talk_to_player():
	$ThoughtBubble.hide()
	$Label.show()
	
func give_quest():
	pass
	
func spawn_quest_pickup_item():
	pass
	
func produce_quest_target():
	pass
	
func ask_city_to_spawn_quest_target():
	
	if city_map.has_method("get_random_quest_target_location"):
		quest_target_location = city_map.get_random_quest_target_location()
	


func _on_InteractionArea_body_entered(body):
	if "detective" in body.name.to_lower():
		
		talk_to_player()
