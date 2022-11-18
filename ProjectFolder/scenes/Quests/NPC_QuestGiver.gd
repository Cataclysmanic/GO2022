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
export var inventory_requirement : String # name of the thing that must be in inventory in order to trigger this quest giver

export var dialog_unmet_requirements : PoolStringArray = ["Hey", "You need to get the thing I'm looking for."]
export var dialog_fulfilled_requirements: PoolStringArray = ["Hey", "Thanks for getting me that thing."]
var currentQuest
var alreadyCompleted = false
var alreadyTaken = false

#signal quest_objective_ready(objective, itemPosition)

var clicks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogLabel.hide()
	$InteractInstruction.hide()
	for item in $PotentialRequiredItems.get_children():
		item.hide()
		item.disable_pickup()
		
	
func init(cityMap):
	city_map = cityMap
	produce_quest_objective()


func talk_to_player():
	$ThoughtBubble.hide()
	$DialogLabel.show()
	
func give_quest():
	pass
	
func get_random_quest_requirement_item():
	var potentialItems = $PotentialRequiredItems.get_children()
	var randomItem = potentialItems[randi()%len(potentialItems)]
	
	return randomItem

func spawn_quest_reward():
	pass

func spawn_quest_objective(targetLocation : Position2D, itemTemplate : Node2D):
	
	if targetLocation == null:
		printerr("NPC Quest Giver needs a location to spawn their objective")

	var questObjective = itemTemplate.duplicate()
	questObjective.set_global_position(targetLocation.get_global_position())
	questObjective.visible = true

	print("NPC_Questiver.gd. Quest objective Target Location = " + str(targetLocation.get_global_position()))
	
	print(questObjective)
	
	
	inventory_requirement = questObjective.item_details["item_name"]
	dialog_unmet_requirements.push_back("Look in " + targetLocation.get_address())
	
	currentQuest = str("Find " + inventory_requirement + " at " + targetLocation.get_address())
	
	dialog_unmet_requirements.push_back(targetLocation.get_details())
#	if city_map.has_method("_on_loot_ready"):
#		if not is_connected("quest_objective_ready", city_map, "_on_loot_ready"):
#			var _err = connect("quest_objective_ready", city_map, "_on_loot_ready")
#			emit_signal("quest_objective_ready", questObjective, targetLocation.get_global_position())
	add_child(questObjective)
	questObjective.set_global_position(targetLocation.get_global_position())
	questObjective.show()
	questObjective.enable_pickup()
	

func produce_quest_objective():
	# come up with some random item?
	var location = get_random_location()
	var itemTemplate = get_random_quest_requirement_item()
	spawn_quest_objective(location, itemTemplate)
	
	
func get_random_location():
	
	return city_map.get_random_quest_target_location()

		
func _unhandled_input(event):
	if $InteractionArea.get_overlapping_bodies().has(Global.player):
		if event.is_action_pressed("interact"):
			advance_dialog(Global.player)
			clicks += 1


func _on_InteractionArea_body_entered(body):
	if body.has_method("is_player") and body.is_player():
		$InteractInstruction.show()
		talk_to_player()
		if !alreadyTaken:
			body.update_journal(currentQuest)
			alreadyTaken = true


func requirements_met(body): 
	# for now this is just a lock and key system. If player has item in inventory, requirements are met.
	# someday we could add different types of requirements.
	
	var requirementsMet = false
	if inventory_requirement == null or inventory_requirement == "":
		requirementsMet = true
	elif body.has_method("has_item") and body.has_item(inventory_requirement):
		requirementsMet = true
		if !alreadyCompleted:
			body.complete_quest(currentQuest)
			alreadyCompleted = true
	return requirementsMet


func advance_dialog(body):
	var dialog_lines
	if requirements_met(body):
		dialog_lines = dialog_fulfilled_requirements
	else:
		dialog_lines = dialog_unmet_requirements

	$DialogLabel.text = dialog_lines[clicks%(len(dialog_lines))]




func _on_InteractionArea_input_event(_viewport, event, _shape_idx):
	if city_map == null:
		city_map = Global.current_city_map
	if event.is_action_pressed("interact"):
		var player = city_map.get_player()
		var bodies_present = $InteractionArea.get_overlapping_bodies()
		if bodies_present.has(player):
			
			advance_dialog(player)
			clicks += 1


func _on_InteractionArea_body_exited(body):
	if body.has_method("is_player") and body.is_player() == true:
		$InteractInstruction.hide()
