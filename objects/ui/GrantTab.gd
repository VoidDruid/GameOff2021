extends Control

export(Color) var texture_color
export(Color) var good_color
export(Color) var bad_color

var grant_uid
var game_manager: GameManager
var action_type = null
var faculty_uid = ""


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_GrButton_pressed(grant_uid, faculty_uid, action_type)


var grant_left_tab_color_path = "HBoxContainer/LeftTabColor"
var grant_background = "HBoxContainer/Background"
var grant_add_info_path = grant_background + "/HBoxContainer/Control"
var grant_label = grant_background + "/HBoxContainer/Label"
var grant_labels_placeholder = grant_background + "/HBoxContainer/VBoxContainer"

func infer_action(grant):
    action_type = game_manager.TAKE_GRANT
    if grant.is_taken:
        action_type = game_manager.WATCH_GRANT
    if grant.is_completed:
        action_type = -1


func add_diff_label(grant, EffectLabel):
    var diff_label = EffectLabel.instance()
    diff_label.text =  str(grant.difficulty) + " " + tr("GRANT_DIFFICULTY")
    diff_label.add_color_override("font_color", bad_color)
    get_node(grant_labels_placeholder).add_child(diff_label)


func add_amount_label(grant, EffectLabel):
    var amount_label = EffectLabel.instance()
    amount_label.text =  str(grant.amount) + " " + tr("GRANT_AMOUNT")
    amount_label.add_color_override("font_color", good_color)
    get_node(grant_labels_placeholder).add_child(amount_label)


func setup_take(grant, PlusButton, EffectLabel):
    var plus = PlusButton.instance()
    var _rs = plus.connect("pressed", self, "_on_Button_pressed")
    get_node(grant_background).add_child(plus)

    if not grant.is_available:
        plus.disabled = true
        plus.modulate = Color(1, 1, 1, 0.4)
        # TODO: add tooltip - why char is unavailable

    add_amount_label(grant, EffectLabel)
    add_diff_label(grant, EffectLabel)


func setup_watch(grant, GrantChance, EffectLabel):
    var chance = GrantChance.instance()
    chance.get_node("ColorRect/Label").text = str(grant.chance) + "%"
    get_node(grant_add_info_path).add_child(chance)

    add_diff_label(grant, EffectLabel)


func setup_assign(grant, TickButton, EffectLabel):
    var tick = TickButton.instance()
    tick.name = "TickButton"
    var _rs = tick.connect("pressed", self, "_on_Button_pressed")
    get_node(grant_background).add_child(tick)
    add_diff_label(grant, EffectLabel)


func setup_none(grant, EffectLabel):
    if grant.is_failed:
        var diff_label = EffectLabel.instance()
        diff_label.text =  tr("FAILED")
        diff_label.add_color_override("font_color", bad_color)
        get_node(grant_labels_placeholder).add_child(diff_label)
    else:
        var amount_label = EffectLabel.instance()
        amount_label.text =  tr("SUCCEEDED")
        amount_label.add_color_override("font_color", good_color)
        get_node(grant_labels_placeholder).add_child(amount_label)


func setup_for_grant(grant, left_tab_color, EffectLabel, PlusButton, GrantChance, TickButton, is_available, is_current, is_completed):
    get_node(grant_left_tab_color_path).color = left_tab_color
    var name_label = get_node(grant_label)
    name_label.text = grant.name + ", " + tr(grant.specialty_uid)
    
    var years_text = ""
    if grant.is_taken:
        years_text += tr("YEARS_LEFT") + ": "
    else:
        years_text += tr("YEARS_GIVEN") + ": "
    years_text += str(grant.years_left) + " "
    if grant.years_left == 1:
        years_text += tr("YEAR")
    elif grant.years_left < 5:
        years_text += tr("YEARS_L5")
    else:
        years_text += tr("YEARS_GE5")
    name_label.hint_tooltip = years_text
    
    grant_uid = grant.uid

    if action_type == null:
        infer_action(grant)
    match action_type:
        -1:
            setup_none(grant, EffectLabel)
        game_manager.ASSIGN_GRANT:
            setup_assign(grant, TickButton, EffectLabel)
        game_manager.WATCH_GRANT:
            setup_watch(grant, GrantChance, EffectLabel)
        game_manager.TAKE_GRANT:
            setup_take(grant, PlusButton, EffectLabel)
