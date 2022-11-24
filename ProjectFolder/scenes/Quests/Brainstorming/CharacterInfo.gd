tool
extends Node2D


export var image : Texture setget set_image

export(String) var character_name : String setget set_character_name
export(String, MULTILINE) var description :String setget set_description
export(String, MULTILINE) var relationships : String setget set_relationships
export(String, MULTILINE) var motives : String setget set_motives
export(String, MULTILINE) var corroboration : String setget set_corroboration
export(String, MULTILINE) var clues : String setget set_clues

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_texture(my_image)
	scale = Vector2(0.15,0.15)

func set_image(my_image):
	if my_image != null:
		$Sprite.set_texture(my_image)
		var desiredSize = Vector2(256,256)
		var texSize = my_image.get_size()
		$Sprite.scale.x = desiredSize.x / texSize.x
		$Sprite.scale.y = desiredSize.y / texSize.y
		var imageRect = $CharacterInfoPanel/VBoxContainer/HBoxContainer/CharacterImage
		imageRect.set_texture(my_image)
	image = my_image

func set_character_name(characterName):
	character_name = characterName
	$CharacterInfoPanel/VBoxContainer/HBoxContainer/CharacterName.text = character_name


func set_motives(motiveText):
	var motiveTextbox = $CharacterInfoPanel/VBoxContainer/HBoxContainer2/RightSide/MotiveOpportunityTextEdit
	motiveTextbox.text = motiveText
	motives = motiveText

func set_description(descriptionText):
	var descriptionTextbox = $CharacterInfoPanel/VBoxContainer/HBoxContainer2/LeftSide/DescriptionTextEdit
	descriptionTextbox.text = descriptionText
	description = descriptionText
	
func set_relationships(relationshipText):
	var relationshipTextbox = $CharacterInfoPanel/VBoxContainer/HBoxContainer2/LeftSide/RelationshipsTextEdit
	relationshipTextbox.text = relationshipText
	relationships = relationshipText
	
func set_corroboration(corroborationText):
	var corroborationTextbox = $CharacterInfoPanel/VBoxContainer/HBoxContainer2/RightSide/CorroborationTextEdit
	corroborationTextbox.text = corroborationText
	corroboration = corroborationText
	
func set_clues(cluesText):
	var cluesTextbox = $CharacterInfoPanel/VBoxContainer/CluesTextEdit
	cluesTextbox.text = cluesText
	clues = cluesText

