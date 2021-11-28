extends Control

export(bool) var character_is_hired
export(Color) var good_color
export(Color) var bad_color

var character_uid
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_ChButton_pressed(character_uid, character_is_hired)


var char_info_panel = "TextureRect/HBoxContainer/VBoxContainer"
var char_top_path = char_info_panel + "/TopRow"
var char_bottom_path = char_top_path + "/BottomRow"
var char_name_label_path = char_top_path + "/CharNameLabel"
var char_cost_label_path = char_top_path + "/CharInfoLabel"

func setup_for_character(character, is_hired):
    get_node(char_name_label_path).text = character.name
    character_uid = character.uid
    get_node(char_cost_label_path).text = (
        str(character.price) + " " + tr("CHARACTER_PRICE") + ", " +
        str(character.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
    )
    if !character.is_available and !is_hired:
         get_node("TextureRect/HBoxContainer/TextureButton").hide()
