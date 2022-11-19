extends VBoxContainer

var quests = [{"type": "JOURNAL:", "quest": "", "status": ""}]

func _process(_delta):
	if !self.is_visible_in_tree():
		close()
		
#If we don't close the popup on input then you may go talk to another NPC and get another quest but 
#the journal wont update since it does only on opening
func _unhandled_key_input(_event):
	$"..".hide()
	close()

func popup():
	for quest in quests:
		var quest_row = HBoxContainer.new()
		var quest_details = Label.new()
		quest_details.text += str(quest.type)
		quest_details.text += str(quest.quest)
		quest_details.text += str(quest.status)
		quest_row.add_child(quest_details)
		add_child(quest_row)
	show()

#Work in progress
#func complete(currentQuest):
#	for quest in get_children():
#		if quest == {"quest": str(currentQuest)}:
#			quest.queue_free()

func close():
	for quest in get_children():
		quest.queue_free()
	hide()
