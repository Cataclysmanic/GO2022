# each quest target is like a lockbox with a requirement.
# the very first quest target in a chain may not have any requirement besides player present.
# successive quest targets might have more complex requirements.

# when the condition is met, quest targets can produce events and/or rewards.

# rewards may be keys to successive quest targets in the chain.
# those keys may spawn a new quest target.


# Should be able to:

# be discovered by player (area2D collision shape)
# test condition (eg: player has item, zone safe)
# spawn event
# spawn loot (may be simple reward or may be key for next quest in chain)


# tell the quest giver (aka previous location) to get lost,

# or send the player back to the quest giver
# spawn dialog

# might look like an icon, or a person, or a piece of furniture


extends Node2D

export var requires : Resource # QuestKey - inventory item
export var produces : Resource # QuestKey - inventory item
export var triggers : Resource # QuestEvent
export var spawns_target : Resource # QuestTarget

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	print("You found the thing at the place")
