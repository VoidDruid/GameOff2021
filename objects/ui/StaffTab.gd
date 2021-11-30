extends Control

var character
var game_manager: GameManager
var is_hired


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_ChButton_pressed(character.uid, is_hired)


var char_name_label_path = "Control/Label"
var char_button_path = "Control/TextureButton"

func _ready():
    is_hired = character.is_hired
    
    get_node(char_name_label_path).text = character.name
    get_node(char_button_path).connect("pressed", self, "_on_Button_pressed")
  
