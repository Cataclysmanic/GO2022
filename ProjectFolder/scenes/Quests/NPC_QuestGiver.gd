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
tool

var city_map
var quest_target_location
var inventory_requirement : String # name of the thing that must be in inventory in order to unlock the quest reward

export var dialog_unmet_requirements : PoolStringArray = ["Hey", "You need to get the thing I'm looking for."]
export var dialog_fulfilled_requirements: PoolStringArray = ["Hey", "Thanks for getting me that thing."]
var currentQuest
var alreadyCompleted = false
var alreadyTaken = false

var rewards = []

#signal quest_objective_ready(objective, itemPosition)

var clicks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): # running in inspector
		return
	else: # running in-game
		$DialogLabel.hide()
		$InteractInstruction.hide()
		disable_collectible_pickups()

		yield(get_tree().create_timer(0.75), "timeout") # give the city time to get ready
		init( Global.current_city_map )
	

func disable_collectible_pickups():
	var folders = [ "Requirements", "Rewards", "PotentialRequiredItems", "PotentialRewards"]
	for folderName in folders:
		if self.has_node(folderName):
			for item in get_node(folderName).get_children():
				item.hide()
				item.disable_pickup()


func init(cityMap):
	city_map = cityMap
	produce_quest_objective()


func _get_configuration_warning():
	if has_node("Rewards") and has_node("Requirements"):
		if $Rewards.get_child_count > 0 and $Requirement.get_child_count > 0:
			return ""
	return "This node requires two node2d children: Requirements and Rewards. Add at least one 2DCollectablePickup.tscn instance as a child of each of those nodes."




func talk_to_player():
	$ThoughtBubble.hide()
	$DialogLabel.show()


func get_random_quest_requirement_item():
	var randomItem
	var potentialItems
	if has_node("Requirements"):
		potentialItems = $Requirements.get_children()
	elif has_node("PotentialRequiredItems"):
		potentialItems = $PotentialRequiredItems.get_children()	
	randomItem = potentialItems[randi()%potentialItems.size()]
	return randomItem
		

func spawn_quest_reward():
	# spawn a bandage and some other reward
	var bandage = load("res://scenes/Items/collectables/2D/Bandage2DPickup.tscn").instance()
	bandage.enable_pickup()
	bandage.show()
	add_child(bandage)
	
	var reward
	if has_node("Rewards"):
		var potentialRewards = $Rewards.get_children()
		var randReward = potentialRewards[randi()%potentialRewards.size()]
		reward = randReward.duplicate()
	elif has_node("PotentialRewards"):
		reward = $PotentialRewards.get_children()[randi()%$PotentialRewards.get_child_count()].duplicate()
	else: # spawn a circumstantial clue if there's no custom reward
		reward = load("res://scenes/Items/collectables/2D/CircumstantialClue2DPickup.tscn").instance()
	reward.enable_pickup()
	reward.show()
	add_child(reward)
	
		

func spawn_quest_objective(targetLocation : Position2D, itemTemplate : Node2D):
	if targetLocation == null:
		printerr("NPC Quest Giver needs a location to spawn their objective")

	var questObjective = itemTemplate.duplicate()
	questObjective.set_global_position(targetLocation.get_global_position())
	questObjective.visible = true

	
	
	inventory_requirement = questObjective.item_details["item_name"]
	
	var preposition = preposition_a_or_an(inventory_requirement)
	
	dialog_unmet_requirements.push_back("I need " + preposition + " " + inventory_requirement + ".")
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
	
	
func preposition_a_or_an(nextWordString):
	if nextWordString.left(1).to_lower() in "aeiou":
		return "an"
	else:
		return "a"


func produce_quest_objective():
	# come up with some random item?
	var location = get_random_location()
	var itemTemplate = get_random_quest_requirement_item()
	if itemTemplate != null:
		spawn_quest_objective(location, itemTemplate)
	
	
func get_random_location():
	
	return city_map.get_random_quest_target_location()

		
func _unhandled_input(event):
	if Engine.is_editor_hint(): # running in inspector
		return
	elif $InteractionArea.get_overlapping_bodies().has(Global.player):
		if event.is_action_pressed("interact"):
			advance_dialog(Global.player)
			clicks += 1
			if !alreadyTaken:
				Global.player.update_journal(currentQuest)
				alreadyTaken = true

func _on_InteractionArea_body_entered(body):
	if Engine.is_editor_hint(): # running in inspector
		return
		
	if body.has_method("is_player") and body.is_player():
		$InteractInstruction.show()
		talk_to_player()
		


func requirements_met(body): 
	# for now this is just a lock and key system. If player has item in inventory, requirements are met.
	# someday we could add different types of requirements.
	
	var requirementsMet = false
	if inventory_requirement == null or inventory_requirement == "":
		requirementsMet = true
	elif body.has_method("has_item") and body.has_item(inventory_requirement):
		requirementsMet = true
		if !alreadyCompleted and alreadyTaken:
			body.complete_quest(currentQuest)
			spawn_quest_reward()
			alreadyCompleted = true
		elif !alreadyCompleted and !alreadyTaken:
			body.update_journal(currentQuest)
			alreadyTaken = true
			body.complete_quest(currentQuest)
			alreadyCompleted = true
	return requirementsMet


func advance_dialog(body):
	var dialog_lines
	$InteractInstruction.hide()
	if requirements_met(body):
		dialog_lines = dialog_fulfilled_requirements
	else:
		dialog_lines = dialog_unmet_requirements

	$DialogLabel.text = dialog_lines[clicks%(len(dialog_lines))]


func _on_InteractionArea_input_event(_viewport, event, _shape_idx):
	if Engine.is_editor_hint(): # running in inspector
		return
	

	if city_map == null:
		city_map = Global.current_city_map
	if event.is_action_pressed("interact"):
		var player = city_map.get_player()
		var bodies_present = $InteractionArea.get_overlapping_bodies()
		if bodies_present.has(player):
			
			advance_dialog(player)
			clicks += 1


func _on_InteractionArea_body_exited(body):
	if Engine.is_editor_hint(): # running in inspector
		return
	elif body.has_method("is_player") and body.is_player() == true:
		$InteractInstruction.hide()
