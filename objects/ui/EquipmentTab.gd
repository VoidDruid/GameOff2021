extends Control

export(Color) var good_color
export(Color) var bad_color
export(Color) var cost_panel_color

var equipment
var faculty_uid
var EffectLabel
var is_available_to_buy
var game_manager: GameManager

func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_EqButton_pressed(faculty_uid, equipment.uid)


var equip_info_panel = "Background/HBoxContainer/VBoxContainer"
var equip_top_path = equip_info_panel + "/TopRow"
var equip_bottom_path = equip_info_panel + "/BottomRow"
var equip_name_label_path = equip_top_path + "/CharNameLabel"
var equip_cost_panel = equip_top_path + "/Panel"
var equip_cost_label_path = equip_cost_panel + "/InfoLabel"


func _ready():
    is_available_to_buy = !equipment.is_active

    get_node(equip_name_label_path).text = equipment.name
    var equip_cost_label = get_node(equip_cost_label_path)
    equip_cost_label.text = ("   " +
        ( str(equipment.price) + " " + tr("CHARACTER_PRICE") if is_available_to_buy else "")
        + "   "
    )
    get_node("Background/TextureButton").hide()
    var button_n

    if not is_available_to_buy:
        button_n = game_manager.BoughtButton_res.instance()
        button_n.modulate = Color(1, 1, 1, 0.4)
    else:
        button_n = game_manager.BuyButton_res.instance()
        #button_n.anchor_top += 0.1
        #button_n.anchor_top -= 0.1
        #button_n.anchor_left += 0.01
        #button_n.anchor_right -= 0.01

    get_node("Background/HBoxContainer/Control").add_child(button_n)

    if !equipment.is_active and !is_available_to_buy:
        button_n.disabled = true
        button_n.modulate = Color(1, 1, 1, 0.4)
        # TODO: add tooltip - why char is unavailable
    else:
        var _rs = button_n.get_node("Button").connect("pressed", self, "_on_Button_pressed")

    var panel = get_node(equip_cost_panel)
    var new_style = StyleBoxFlat.new()
    new_style.set_corner_radius_all(5)
    new_style.set_bg_color(cost_panel_color)
    panel.set('custom_styles/panel', new_style)

    var bottom_row = get_node(equip_bottom_path)
    for modifier in equipment.modifiers:
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
    panel.rect_min_size.x = equip_cost_label.rect_size.x

    if not is_available_to_buy:
        panel.hide()

