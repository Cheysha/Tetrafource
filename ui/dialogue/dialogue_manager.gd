extends CanvasLayer

#---File---#
var file_name: String = "dialogue_1" # File Name Imported from Tiled
var nodes # contains all the nodes of the current dialogue

#----DATA (from file)-----#
var curent_node_id = -1 # handles the current node we are traversing Note: -1 exits the dialogue
var curent_node_name # name of the speaker 
var curent_node_text # dialogue text
var curent_node_next_id # connect to the next node Note: ignored if curent_node_choices has things inside
var curent_node_choices = [] # If you want more than one possible answear, you should fill this up

var force = false # force start the dialogue
var random = false # Start from random node
#Edited 12/7
var is_finished = false
#var visible = false


#------UI--------#
@onready var choiceBox = $DialogueUI/ChoiceBox
@onready var dialogueText = $DialogueUI/DialogueText 
@onready var dialoguePanel = $DialogueUI #Less rewritting if you want to move the script to another object
@onready var dialogueName = $DialogueUI/DialogueName
#@onready var tween = $DialogueUI/Tween
@onready var dialogueButtons = [$DialogueUI/ChoiceBox/Button1,$DialogueUI/ChoiceBox/Button2]

signal finished

func _input(event):
	#EDITED 12/8
	if Input.is_action_pressed("B"):
		#tween.set_speed_scale(2.0)
		pass
	else:
		#tween.set_speed_scale(1.0)
		pass
	if Input.is_action_just_pressed("UP"):
		dialogueButtons[0].grab_focus()
	if Input.is_action_just_pressed("DOWN"):
		dialogueButtons[1].grab_focus()
	
#-----Load JSON File-----#
#EDITED 12/8
func LoadFile(fname):
	file_name = fname
	#var file = File.new()
	#var file = FileAccess.exi
	if FileAccess.file_exists("res://dialogue/"+file_name+".json"):
		var file = FileAccess.open("res://dialogue/" + file_name + ".json",FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var json_result = test_json_conv.get_data()
		force = bool(json_result["Force"])
		random = bool(json_result["Random"])
		curent_node_id = 0
		nodes = json_result["Nodes"]
	else:
		print("Dialogue: File Open Error")
	#file.close()
	if force:
		StartDialogue()
	
#-----Traversing Graph-----#
func StartDialogue():
	if nodes:
		if random:
			var temp = []
			for x in nodes:
				temp.append(x["id"])
			curent_node_id = temp[randi()%temp.size()]
		else:
			curent_node_id = 0
		HandleNode()
		
	else:
		print("Dialogue: Could not Find Nodes")

func EndDialogue():
		curent_node_id = -1

func NextNode(id):
	curent_node_id = id
	HandleNode()

#----Handle Current Node-----#
func HandleNode():
	if curent_node_id < 0 :
		EndDialogue()
	else:
		if !GrabNode(curent_node_id):
			EndDialogue()
	UpdateUI()
	
func GrabNode(id):
	for node in nodes:
		if int(node["id"]) == id:
			curent_node_name = node["name"]
			curent_node_text = node["text"]
			curent_node_next_id = int(node["next_id"])
			curent_node_choices = node["choices"]
			return true
	return false

#----Update UI-----#
func UpdateUI():
	#EDITED 12/8
	#if dialogueText.percent_visible < 1:
	if dialogueText.visible_ratio < 1:
		choiceBox.hide()
	if curent_node_id >= 0:
		Dialogue_Anim()
		dialoguePanel.show()
		for x in dialogueButtons:
			x.hide()
			#disconnect buttons
			if x.is_connected("pressed", Callable(self, "_on_Button_Pressed")):
				x.disconnect("pressed", Callable(self, "_on_Button_Pressed"))
			
		dialogueName.text = curent_node_name
		dialogueText.text = curent_node_text
		if curent_node_choices.size() > 0:
			for x in clamp(curent_node_choices.size(),0,3):
				dialogueButtons[x].text = curent_node_choices[x]["text"]
				#connecto to button
				dialogueButtons[x].connect("pressed", Callable(self, "_on_button_Pressed").bind(curent_node_choices[x]["next_id"]))
				dialogueButtons[x].show()
				dialogueButtons[0].grab_focus()
				
		else:
			dialogueButtons[0].text = "Continue"
			if dialogueButtons[0].text == "Continue":
				choiceBox.position.y = 700
			dialogueButtons[0].show()
			#connect to the button
			dialogueButtons[0].connect("pressed", Callable(self, "_on_Button_Pressed").bind(curent_node_next_id))

	else:
		get_parent().action_cooldown = 10
		get_parent().state = "default"
		dialogueText.visible_ratio = 0
		emit_signal("finished")
		queue_free()
		

#-----Text Animation-----#
func Dialogue_Anim():
	#EDITED12/8
	is_finished = false
	$"DialogueUI/next-indicator".hide()
	var line_speed = (curent_node_text.length() * 0.02)
	#EDITED 12/8
	var t : Tween = create_tween()
	t.tween_property(dialogueText,"visible_ratio",1,line_speed)
	t.tween_method(Callable(self,"_play_snd"),0,0,0)
	t.tween_callback(Callable(self,"_on_Tween_tween_all_completed"))
	#tween.interpolate_property(dialogueText,"percent_visible",0,1,line_speed, Tween.TRANS_LINEAR)
	#tween.start()

#-----On Button Pressed-----#
func _on_Button_Pressed(id):
	sfx.play("item_select")
	NextNode(id)

#-----Initiate Dialogue-----#
func Begin_Dialogue():
	choiceBox.position.y = -33
	LoadFile(file_name)
	StartDialogue()

#-----Prompt Once Text Complete-----#
func _on_Tween_tween_all_completed():
	#EDITED12/8
	is_finished = true
	$"DialogueUI/next-indicator".show()
	if curent_node_choices.size() != null:
		choiceBox.show()
		dialogueButtons[0].grab_focus()

#-----Text Tween Sound Effect----#
func _on_Tween_tween_step(object, key, elapsed, value):
	sfx.play("dialogue")
	
func _play_snd(trash):
	sfx.play("dialogue")
