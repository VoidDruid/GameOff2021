extends Node

export(NodePath) var simulation_node_path
var simulation: SimulationCore
var MainWindow: Control
var CurrentGameWindow: Control
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
	CurrentGameWindow = load("res://objects/Characters.tscn").instance()
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
