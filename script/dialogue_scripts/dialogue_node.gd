extends Control
class_name dialogue_node

@onready var margin_container: MarginContainer = $Panel/MarginContainer
@onready var sprite: TextureRect = $Panel/MarginContainer/Sprite
@onready var border: TextureRect = $Panel/MarginContainer/Sprite/Border
@onready var dialogue_text: Label = $Panel/VBoxContainer/DialogueText
@onready var question_box: VBoxContainer = $Panel/VBoxContainer/question_box
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer
var question_label = preload('res://scenes/question_label.tscn')
var option = 0

var current_loaded_dialogue : Dialogue
var c = 0

func updateText(label : Label ,newValue : String):
	label.text = newValue

func updateSprite(sp : TextureRect, new : Texture):
	if new != null and new != sp.texture:
		sp.texture = new

func question_handler(i : int):
	#0 = Down
	#1 = Up
	
	if i == 0: #Down
		if option == len(current_loaded_dialogue.messages[c].questions) - 1:
			question_box.get_node("question" + str(option)).modulate = Color(1, 1, 1, 1)
			option = 0
		else:
			question_box.get_node("question" + str(option)).modulate = Color(1, 1, 1, 1)
			option+=1
	if i == 1: #Up
		if option == 0:
			question_box.get_node("question" + str(option)).modulate = Color(1, 1, 1, 1)
			option = len(current_loaded_dialogue.messages[c].questions) - 1
		else:
			question_box.get_node("question" + str(option)).modulate = Color(1, 1, 1, 1)
			option-=1
	#print(question_box.get_node("question" + str(option)))
	question_box.get_node("question" + str(option)).modulate = Color("#15ee00")

func start(new_dialogue : Dialogue):
	if new_dialogue != current_loaded_dialogue:
		current_loaded_dialogue = new_dialogue
		c = 0
		Ui.fade_in(self)
		anchor(current_loaded_dialogue.messages[c].sprite_pos)
		updateSprite(sprite, current_loaded_dialogue.messages[c].sprite)
		updateSprite(border, current_loaded_dialogue.messages[c].border)
		updateText(dialogue_text, new_dialogue.messages[c].text)

func loadNextMessage():
	if current_loaded_dialogue.messages[c] is Question:
		question_handler(1)
		return
	if current_loaded_dialogue==null: return
	
	c+=1
	
	if c>=len(current_loaded_dialogue.messages):
		c=0
		await Ui.fade_out(self)
		updateText(dialogue_text, "")
		current_loaded_dialogue.onDialogueEnd()
		current_loaded_dialogue = null
		return
	
	Ui.fade_out(margin_container)
	await Ui.fade_out(v_box_container)
	
	# -invis ####################################
	
	anchor(current_loaded_dialogue.messages[c].sprite_pos)
	updateSprite(sprite, current_loaded_dialogue.messages[c].sprite)
	updateSprite(border, current_loaded_dialogue.messages[c].border)
	updateText(dialogue_text, current_loaded_dialogue.messages[c].text)
	if current_loaded_dialogue.messages[c] is Question:
		for i in range(len(current_loaded_dialogue.messages[c].questions)):
			var q = question_label.instantiate()
			q.text = current_loaded_dialogue.messages[c].questions[i].question
			question_box.add_child(q)
			q.name = "question" + str(i)
		question_box.get_node("question" + str(option)).modulate = Color("#15ee00")
	
	# -visible ####################################
	
	Ui.fade_in(margin_container)
	await Ui.fade_in(v_box_container)

func confirm():
	if current_loaded_dialogue.messages[c] is not Question: return
	for i in range(len(current_loaded_dialogue.messages[c].questions)):
		question_box.get_node("question" + str(i)).queue_free()
	
	if current_loaded_dialogue.messages[c].lock_dialogue == true:
		current_loaded_dialogue.question(current_loaded_dialogue.messages[c].questions[option].response)
	else:
		current_loaded_dialogue = current_loaded_dialogue.messages[c].questions[option].response
		
	c = -1
	loadNextMessage()

func anchor(pos):
	# 0 = direita
	# 1 = esquerda
	# 2 = nenhum
	
	if pos == 0:
		#print('0')
		v_box_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT,Control.PRESET_MODE_KEEP_SIZE,37)
		margin_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE,5)
		sprite.modulate = Color (1, 1, 1, 1)
	elif pos == 1:
		#print('1')
		v_box_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE,5)
		margin_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT,Control.PRESET_MODE_KEEP_SIZE,5)
		sprite.modulate = Color (1, 1, 1, 1)
	elif pos == 2:
		#print('2')
		sprite.modulate = Color (1, 1, 1, 0)
