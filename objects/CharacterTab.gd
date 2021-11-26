extends Control

export(String) var character_uid
export(NodePath) var game_manager_path
var game_manager: GameManager
# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node(game_manager_path)


func _on_Button_pressed():
	if game_manager != null:
		game_manager.on_Button_pressed(character_uid)
