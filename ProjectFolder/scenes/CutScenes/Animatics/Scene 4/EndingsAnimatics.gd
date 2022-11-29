#Plays outro animatics for endgame scenarios.

#Note, there can be various triggers to get here..
# IO._on_collectible_picked_up() == HappyEnding
# 
# Main.gd / Global.world_controller has a method to spawn these animations:
	# Global.world_controller._on_ending_requested(endingName)

extends CanvasLayer


var ending_scripts = {
	"GetOutOfJailCard": [],
	"CollectEvidence": [],
	"BeatTheBoss": [],
	"GoToJail":[],
}



var current_script : Array = []
var current_line : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#moved scripts directly into the Label nodes in the inspector
	#populate_scripts()

#	if Global.chosen_ending != null:
#		play_ending(Global.chosen_ending)
#	else:
#		yield(get_tree().create_timer(2.0), "timeout")
#		play_ending("GetOutOfJailCard")

func populate_scripts():
	ending_scripts["GetOutOfJailCard"].push_back("I didn't expect it to be this easy: do a couple of favours, scratch a few backs. This city seethes with corruption. Now I'm part of it. Or maybe, I always have been.")
	
	ending_scripts["CollectEvidence"].push_back("This city runs on violence. Smash enough heads and eventually you'll get the info you need. The Labour Union gave up Veronica Winter, the cold-blooded ice queen snake femme fatale. She obviously set you up for murder. The labour union now corroborates your story. Perhaps the judge will see it your way.")

	ending_scripts["BeatTheBoss"].push_back("I never expected Tommy to be so damn corrupt. He's alive, after staging his death. With the help of his Moll, Veronica, they framed me for murder. A murder I didn't commit. A murder that didn't even happen. Diabolical! Still, I got the last word.")

	ending_scripts["GoToJail"].push_back("Cold, dark, unforgiving city. First I'm framed for murder, then beaten senseless by Romano's thugs, now I'm going to rot in jail. Typical.")

func play_ending(_endingName):
	# Changed to autoplay specific animations: 4 distinct scenes, each with their own animation.
		# was easier than having 4 animations in one scene.
	return
	
#	if $AnimationPlayer.has_animation(endingName):
#		current_script = ending_scripts[endingName]
#		current_line = 0
#
#
#		find_node("EndingScriptText").text = current_script[current_line]
#
#		#$AnimationPlayer.play(endingName)
#		$AnimationPlayer.play("BrokenGetOutOfJailCard")
#	else:
#		printerr("EndingsAnimatics.gd play_ending(): animation not found for: " + endingName)



func advance_script():
	current_line = int(min(current_line +1, current_script.size()-1))
	$VBoxContainer/EndingScriptText.text = current_script[current_line]


func _on_RebootButton_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")
