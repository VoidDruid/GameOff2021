extends Control

export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color

var EffectLabel
var game_manager: GameManager
var leader

var leader_cost_panel_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Control/Panel"
var leader_cost_label_path = leader_cost_panel_path + "/Label"
var leader_name_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/LeaderName/Label"
var leader_effects_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Effects"

func _on_Button_pressed():
    if game_manager != null:
        pass
        #game_manager.on_ChButton_pressed(character.uid, is_hired)
        
