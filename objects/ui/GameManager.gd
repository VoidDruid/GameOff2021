extends Node
class_name GameManager

export(NodePath) var simulation_node_path
var simulation: SimulationCore
var MainWindow: Control
var CurrentGameWindow
var LogTabText: RichTextLabel
# signals
signal update_log(logs)

func _ready():
	simulation = get_node(simulation_node_path)
	MainWindow = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/MainWindow")
	LogTabText = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainer/Logs/Text")
	LogTabText.text = ""
	var _rs = connect("update_log", self, "_on_Update_log")


func _process(_delta):
	pass


func _on_Characters_pressed():
	if CurrentGameWindow != null:
		CurrentGameWindow.queue_free()
	buildCharactersWindow()
	MainWindow.add_child(CurrentGameWindow)
	


func _on_Grants_pressed():
	if CurrentGameWindow != null:
		CurrentGameWindow.queue_free()
	CurrentGameWindow = load("res://objects/Grants.tscn").instance()
	MainWindow.add_child(CurrentGameWindow)


func _on_Faculty_pressed(_num):
	if CurrentGameWindow != null:
		CurrentGameWindow.queue_free()
	CurrentGameWindow = load("res://objects/Faculty.tscn").instance()
	MainWindow.add_child(CurrentGameWindow)
	
func _on_Update_log(log_list):
	for log_ in log_list:
		LogTabText.add_text(log_ + "\n")
	
func _on_First_pressed():
	#_on_Faculty_pressed(1)
	emit_signal("update_log", ["log","log2"])


func _on_Second_pressed():
	_on_Faculty_pressed(2)


func _on_Third_pressed():
	_on_Faculty_pressed(3)


func _on_Fourth_pressed():
	_on_Faculty_pressed(4)


func _on_Fifth_pressed():
	_on_Faculty_pressed(5)
	
func on_Button_pressed(ch_id):
	LogTabText.add_text(str(ch_id) + "\n")
	
func buildCharactersWindow():
	CurrentGameWindow = load("res://objects/Characters.tscn").instance()
	CurrentGameWindow.get_node("Characters/VBoxAvailable/Label").text = "Available Characters"
	CurrentGameWindow.get_node("Characters/VBoxHired/Label").text = "Hired Characters"
	var dt = simulation.get_characters_data()
	for ch in dt.available_characters:
		var chTab = load("res://objects/CharacterTab.tscn").instance()
		chTab.get_node("Info").text = ch.name + " price: " + str(ch.price)
		chTab.get_node("Button").text = "Hire"
		chTab.character_uid = ch.uid
		chTab.game_manager_path = @"/root/Main/UI/GameUI"
		#if !ch.is_available:
		#chTab.get_node("Button").hide()
		
		CurrentGameWindow.get_node("Characters/VBoxAvailable/Available/VBoxContainer").add_child(chTab)
	
	for ch in dt.hired_characters:
		var chTab = load("res://objects/CharacterTab.tscn").instance()
		chTab.get_node("Info").text = ch.name + " per year: " + str(ch.price)
		chTab.get_node("Button").text = "Fire"
		CurrentGameWindow.get_node("Characters/VBoxHired/Hired/VBoxContainer").add_child(chTab)
