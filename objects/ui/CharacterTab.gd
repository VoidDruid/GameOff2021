extends Control

export(bool) var character_is_hired
export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color
export(Color) var available_panel_color

var character
var EffectLabel
var is_hired
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_ChButton_pressed(character.uid, character_is_hired)


var char_info_panel = "Background/HBoxContainer/VBoxContainer"
var char_top_path = char_info_panel + "/TopRow"
var char_bottom_path = char_info_panel + "/BottomRow"
var char_name_label_path = char_top_path + "/CharNameLabel"
var char_cost_panel = char_top_path + "/Panel"
var char_cost_label_path = char_cost_panel + "/CharInfoLabel"


func _ready():
    get_node(char_name_label_path).text = character.name
    var char_cost_label = get_node(char_cost_label_path)
    char_cost_label.text = ("   " +
        ("" if is_hired else str(character.price) + " " + tr("CHARACTER_PRICE") + ", ") +
        str(character.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
        + "   "
    )
    if !character.is_available and !is_hired:
         get_node("Background/HBoxContainer/TextureButton").hide()

    var panel = get_node(char_cost_panel)
    var new_style = StyleBoxFlat.new()
    new_style.set_corner_radius_all(5)
    new_style.set_bg_color(hired_panel_color if is_hired else available_panel_color)
    panel.set('custom_styles/panel', new_style)

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

    # waiting for rect_size of label to be recalculated
    yield(get_tree(), "idle_frame")
    panel.rect_min_size.x = char_cost_label.rect_size.x

