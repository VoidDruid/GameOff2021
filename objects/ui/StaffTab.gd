extends Control

var character
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_ChButton_pressed(character.uid, character.faculty_uid, game_manager.STAFF_REMOVE)


var char_name_label_path = "Control/Label"
var char_button_path = "Control/TextureButton"

func _ready():
    get_node(char_name_label_path).text = character.name
    var _rs = get_node(char_button_path).connect("pressed", self, "_on_Button_pressed")
  
