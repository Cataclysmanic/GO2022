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

#export var no_key_spawn : bool # if true, don't spawn the quest requirement.. assume it's already present on the map or comes as a result of some other quest.
export var spawn_random_quest_objective : bool = true  # inverse of "no_key_spawn"
export var npc_name : String
export (String, MULTILINE) var key_spawn_instructions : String = "Set no_key_spawn to true if the quest-giver's requirement is furnished by another quest-giver as a reward. Otherwise the quest requirement will spawn randomly somewhere no the map."
export var dialog_unmet_requirements : PoolStringArray = ["Hey", "You need to get the thing I'm looking for."]
export var dialog_fulfilled_requirements: PoolStringArray = ["Hey", "Thanks for getting me that thing."]
export (String, MULTILINE) var dialog_instructions : String = "Fill in the PoolStringArrays with dialog to be spoken to the player. First is if they don't have the quest objective in inventory, second is after retrieiving the quest objective."
export var Sprite_Tex : Texture
export var Portrait_Tex : Texture

var city_map
var quest_target_location
var inventory_requirement : String # name of the thing that must be in inventory in order to unlock the quest reward
var popin_dialog

var currentQuest
var alreadyCompleted = false
var alreadyTaken = false

var rewards = []

#signal quest_objective_ready(objective, itemPosition)

var clicks = 0

enum States { INITIALIZING, READY, TALKING, MISSING, DEAD }
var State = States.INITIALIZING



# Called when the node enters the scene tree for the first time.
func _ready():
	popin_dialog = find_node("PopInDialog")
	if Engine.is_editor_hint(): # running in inspector
		popin_dialog = find_node("PopInDialog")
		init_textures()
	else: # running in-game
		init_textures()

		$DialogLabel.hide()
		$InteractInstruction.hide()
		if has_node("CanvasLayer/Dialogue"):
			$CanvasLayer/Dialogue.hide()
		disable_collectible_pickups()

		yield(get_tree().create_timer(0.75), "timeout") # give the city time to get ready
		init( Global.current_city_map )
		State = States.READY


func init_textures():
	if Sprite_Tex != null:
		$Sprite.set_texture(Sprite_Tex)
	if Portrait_Tex != null and has_node("PopInDialog"):
		if popin_dialog != null:
			popin_dialog.set_portrait(Portrait_Tex)
	

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


func _process(_delta):
	if Engine.is_editor_hint(): # running in inspector
		if $Sprite.get_texture().get_path() == "res://icon.png":
			init_textures()
		
func _get_configuration_warning():
	if has_node("Rewards") and has_node("Requirements"):
		if $Rewards.get_child_count() > 0 and $Requirement.get_child_count() > 0:
			return "all good"
		else:
			return "Rewards and Requirements nodes should be populated with Collectible Items as children."
	return "This node requires TWO children: Requirements and Rewards, with at least one 2DCollectablePickup.tscn child each. You should also set the Sprite_Tex and Portrait_Tex"




func talk_to_player():
	$ThoughtBubble.hide()
	$DialogLabel.show() # says "Hey", and that's about it.


func get_random_quest_requirement_item():
	var randomItem
	var potentialItems
	if has_node("Requirements") and $Requirements.get_child_count() > 0:
		potentialItems = $Requirements.get_children()
	elif has_node("PotentialRequiredItems"):
		potentialItems = $PotentialRequiredItems.get_children()	
	
	if potentialItems.size() > 0:
		randomItem = potentialItems[randi()%potentialItems.size()]
		return randomItem
		

func spawn_quest_reward():
	# spawn a bandage and some other reward
	
	var bandage = load("res://scenes/Items/collectables/2D/Bandage2DPickup.tscn").instance()
	bandage.enable_pickup()
	bandage.show()
	# this may be breaking quest rewards if it sits on top and player can't grab it.
	bandage.position += Vector2(rand_range(30.0, 50.0), 0).rotated(randf()*2*PI)
	add_child(bandage)
	bandage.set_global_scale(Vector2(0.5,0.5))

	var reward
	print("NPC_QuestGiver.gd spawn_quest_reward() spawning reward...")
	if has_node("Rewards") and $Rewards.get_child_count() > 0:
		var potentialRewards = $Rewards.get_children()
		var randReward = potentialRewards[randi()%potentialRewards.size()]
		reward = randReward.duplicate()
	elif has_node("PotentialRewards"):
		reward = $PotentialRewards.get_children()[randi()%$PotentialRewards.get_child_count()].duplicate()
	else: # spawn a circumstantial clue if there's no custom reward
		reward = load("res://scenes/Items/collectables/2D/CircumstantialClue2DPickup.tscn").instance()
	add_child(reward)
	reward.set_global_scale(Vector2.ONE)
	reward.set_global_position(self.global_position)
	reward.position += Vector2(rand_range(30.0, 50.0), 0).rotated(randf()*2*PI)
	print("reward spawned : " + reward.item_details["item_name"] + " at " + str(reward.get_global_position()))
	print("meanwhile, player is at " + str(Global.player.get_global_position()))
	print("and player scale is " + str(Global.player.get_global_scale()))
	reward.enable_pickup()
	reward.show()
		

func spawn_quest_objective(targetLocation : Position2D, itemTemplate : Node2D):
	# targetLocation may be null, in the case of no_key_spawn

	var questObjective
	if spawn_random_quest_objective and targetLocation != null:
		questObjective = itemTemplate.duplicate()
		#questObjective.set_global_position(targetLocation.get_global_position())
		questObjective.show()
		questObjective.enable_pickup()
		add_child(questObjective)
		#does order of setting position before/after add_child() matter?
		questObjective.set_global_position(targetLocation.get_global_position())
		
	else: # don't spawn a copy, just read the info
		questObjective = itemTemplate
		
	inventory_requirement = questObjective.item_details["item_name"]
		
	var preposition = preposition_a_or_an(inventory_requirement)
	dialog_unmet_requirements.push_back("I need " + preposition + " " + inventory_requirement + ".")
	
	if spawn_random_quest_objective:
		dialog_unmet_requirements.push_back("Look in " + targetLocation.get_address())
		dialog_unmet_requirements.push_back(targetLocation.get_details())
		currentQuest = str("Find " + inventory_requirement + " at " + targetLocation.get_address() + " for " + npc_name + ".")
	else: # don't spawn a quest requirement in a random location.. it must exist in-world already
		currentQuest = str("Find " + inventory_requirement + " for " + npc_name + ".")
		


func preposition_a_or_an(nextWordString):
	if nextWordString.left(1).to_lower() in "aeiou":
		return "an"
	else:
		return "a"


func produce_quest_objective():
	
	# come up with some random item?
	var location : Position2D
	if spawn_random_quest_objective:
		location = get_random_location()
	var itemTemplate = get_random_quest_requirement_item()
	if itemTemplate != null:
		spawn_quest_objective(location, itemTemplate)
	
	
	
func get_random_location() -> Position2D :
	return city_map.get_random_quest_target_location()


func _unhandled_input(_event):
	if Engine.is_editor_hint(): # running in inspector
		return
	elif $InteractionArea.get_overlapping_bodies().has(Global.player): # this might not work while paused
		if Input.is_action_just_pressed("interact") and State == States.READY:
			popup_dialogue_box()
	if Global.controller:
		$InteractInstruction.text = "[Triangle/Y/X]"
	else:
		$InteractInstruction.text = "[F]"


func _on_InteractionArea_body_entered(body):
	if Engine.is_editor_hint(): # running in inspector
		return
		
	if body.has_method("is_player") and body.is_player():
		$InteractInstruction.show()
		talk_to_player()
		

func popup_dialogue_box():

	if has_node("PopInDialog"):
		
		if requirements_met(Global.player):
			popin_dialog.set_text(dialog_fulfilled_requirements)
		else:
			popin_dialog.set_text(dialog_unmet_requirements)
		popin_dialog.popin()

		State = States.TALKING
	

func quest_accepted():
	if !alreadyTaken:
		Global.player.update_journal(currentQuest)
		alreadyTaken = true

func quest_rejected():
	#disappear?
	#aggro?
	# make a timed demand, "or else"?
	pass


func hide_dialogue_box():
	if has_node("PopInDialog"):
		popin_dialog.popout()
		State = States.READY


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


func advance_dialogue():
	$InteractInstruction.hide()
	$PopInDialog.advance_dialogue()
	

func _on_InteractionArea_input_event(_viewport, event, _shape_idx):
	if Engine.is_editor_hint(): # running in inspector
		return
	

	if city_map == null:
		city_map = Global.current_city_map
	if event.is_action_pressed("interact"):
		var player = city_map.get_player()
		var bodies_present = $InteractionArea.get_overlapping_bodies()
		if bodies_present.has(player):
			
			advance_dialogue()
			clicks += 1


func _on_InteractionArea_body_exited(body):
	if Engine.is_editor_hint(): # running in inspector
		return
	elif body.has_method("is_player") and body.is_player() == true:
		$InteractInstruction.hide()



	

#
#func _on_YesButton_pressed():
#	hide_dialogue_box()
#
#func _on_NoButton_pressed():
#	hide_dialogue_box()
	
func _on_dialog_finished():
	State = States.READY
