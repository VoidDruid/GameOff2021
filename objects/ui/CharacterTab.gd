extends Control

export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color
export(Color) var available_panel_color

export(Texture) var plus_texture_normal
export(Texture) var plus_texture_pressed
export(Texture) var plus_texture_hover

export(Texture) var cross_texture_normal
export(Texture) var cross_texture_pressed
export(Texture) var cross_texture_hover

export(Texture) var tick_texture_normal
export(Texture) var tick_texture_pressed
export(Texture) var tick_texture_hover

var character
var EffectLabel
var is_hired
var game_manager: GameManager
var action_type = null
var faculty_uid = ""


func _on_Button_pressed():
    if game_manager == null:
        return
    match action_type:
        -1:
            return
        _:
            game_manager.on_ChButton_pressed(character.uid, faculty_uid, action_type)


var char_info_panel = "Background/HBoxContainer/VBoxContainer"
var char_top_path = char_info_panel + "/TopRow"
var char_bottom_path = char_info_panel + "/BottomRow"
var char_name_label_path = char_top_path + "/CharNameLabel"
var char_cost_panel = char_top_path + "/Panel"
var char_cost_label_path = char_cost_panel + "/InfoLabel"


func infer_action():
    if not is_hired:
        action_type = game_manager.CHARACTER_HIRE
    else:
        action_type = game_manager.CHARACTER_FIRE


func setup_hire(button):
    if !character.is_available and !is_hired:
        self.queue_free()  # TODO: is this better?
        button.disabled = true
        button.modulate = Color(1, 1, 1, 0.4)
    else:
        button.connect("pressed", self, "_on_Button_pressed")
    button.texture_normal = plus_texture_normal
    button.texture_hover = plus_texture_hover
    button.texture_pressed = plus_texture_pressed


func setup_fire(button):
    button.connect("pressed", self, "_on_Button_pressed")
    button.texture_normal = cross_texture_normal
    button.texture_hover = cross_texture_hover
    button.texture_pressed = cross_texture_pressed
    button.anchor_top += 0.1
    button.anchor_top -= 0.1
    button.anchor_left += 0.01
    button.anchor_right -= 0.01


func setup_assign(button):
    button.texture_normal = tick_texture_normal
    button.texture_hover = tick_texture_hover
    button.texture_pressed = tick_texture_pressed
    button.connect("pressed", self, "_on_Button_pressed")


func setup_none(button):
    button.queue_free()


func _ready():
    is_hired = character.is_hired

    var name_label = get_node(char_name_label_path)
    name_label.text = tr(character.name) + ", " + tr(character.title)
    name_label.hint_tooltip = tr(character.specialty_uid)
    var char_cost_label = get_node(char_cost_label_path)
    char_cost_label.text = ("   " +
        ("" if is_hired else str(character.price) + " " + tr("CHARACTER_PRICE") + ", ") +
        str(character.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
        + "   "
    )

    var button_n = get_node("Background/TextureButton")
    if action_type == null:
        infer_action()
    match action_type:
        game_manager.CHARACTER_FIRE:
            setup_fire(button_n)
        game_manager.CHARACTER_HIRE:
            setup_hire(button_n)
        game_manager.LEADER_ASSIGN:
            setup_assign(button_n)
        game_manager.STAFF_ADD:
            setup_hire(button_n)

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

