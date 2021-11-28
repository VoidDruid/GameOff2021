extends Control

export(bool) var character_is_hired
export(Color) var good_color
export(Color) var bad_color

var character_uid
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_ChButton_pressed(character_uid, character_is_hired)


var char_info_panel = "Background/HBoxContainer/VBoxContainer"
var char_top_path = char_info_panel + "/TopRow"
var char_bottom_path = char_info_panel + "/BottomRow"
var char_name_label_path = char_top_path + "/CharNameLabel"
var char_cost_label_path = char_top_path + "/CharInfoLabel"

func setup_for_character(character, EffectLabel, is_hired):
    get_node(char_name_label_path).text = character.name
    character_uid = character.uid
    get_node(char_cost_label_path).text = (
        str(character.price) + " " + tr("CHARACTER_PRICE") + ", " +
        str(character.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
    )
    if !character.is_available and !is_hired:
         get_node("Background/HBoxContainer/TextureButton").hide()

    var bottom_row = get_node(char_bottom_path)
    for modifier in character.modifiers:
        var mod_label = EffectLabel.instance()
        var mod_text = "+" if modifier.value > 0 else ""
        mod_text += str(modifier.value if modifier.absolute else int(modifier.value * 100))
        mod_text += "%" if not modifier.absolute else ""
        mod_text += " " + tr("MOD_" + modifier.property.to_upper())
        mod_label.text = mod_text
        mod_label.add_color_override("font_color", good_color if modifier.positive else bad_color)
        bottom_row.add_child(mod_label)
