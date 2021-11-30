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
        
# Called when the node enters the scene tree for the first time.
func _ready():
    if leader != null:
        var leader_cost_label = get_node(leader_cost_label_path)
        leader_cost_label.text = ("   " +
            str(leader.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
            + "   "
        )
        var panel = get_node(leader_cost_panel_path)
        var new_style = StyleBoxFlat.new()
        new_style.set_corner_radius_all(5)
        new_style.set_bg_color(hired_panel_color)
        panel.set('custom_styles/panel', new_style)
        yield(get_tree(), "idle_frame")
        panel.rect_min_size.x = leader_cost_label.rect_size.x

        get_node(leader_name_path).text = leader.name

        var leader_effects = get_node(leader_effects_path)
        for modifier in leader.modifiers:
            var mod_label = EffectLabel.instance()
            var mod_text = "+" if modifier.value > 0 else ""
            mod_text += str(modifier.value if modifier.absolute else int(modifier.value * 100))
            mod_text += "%" if not modifier.absolute else ""
            mod_text += " " + tr("MOD_" + modifier.property.to_upper())
            mod_label.text = mod_text
            mod_label.add_color_override("font_color", good_color if modifier.positive else bad_color)
            leader_effects.add_child(mod_label)
