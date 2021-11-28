extends Control

export(Color) var texture_color

var grant_uid
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_GrButton_pressed(grant_uid)


var grant_left_tab_color_path = "HBoxContainer/LeftTabColor"
var grant_texture_color_path = "HBoxContainer/BackgroundColor"
var grant_add_info_path = "HBoxContainer/Background/HBoxContainer/Control"

func setup_for_grant(grant, left_tab_color, EffectLabel, PlusButton, GrantChance, is_available, is_current, is_completed):
    get_node(grant_left_tab_color_path).color = left_tab_color
    if is_available:
        get_node(grant_add_info_path).add_child(PlusButton.instance())
    elif is_current:
        get_node(grant_add_info_path).add_child(GrantChance.instance())

