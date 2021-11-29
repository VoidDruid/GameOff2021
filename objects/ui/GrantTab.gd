extends Control

export(Color) var texture_color
export(Color) var good_color
export(Color) var bad_color

var grant_uid
var game_manager: GameManager


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_GrButton_pressed(grant_uid)


var grant_left_tab_color_path = "HBoxContainer/LeftTabColor"
var grant_background = "HBoxContainer/Background"
var grant_add_info_path = grant_background + "/HBoxContainer/Control"
var grant_label = grant_background + "/HBoxContainer/Label"
var grant_labels_placeholder = grant_background + "/HBoxContainer/VBoxContainer"

func setup_for_grant(grant, left_tab_color, EffectLabel, PlusButton, GrantChance, is_available, is_current, is_completed):
    get_node(grant_left_tab_color_path).color = left_tab_color
    get_node(grant_label).text = grant.name
    grant_uid = grant.uid

    if is_available:
        var plus = PlusButton.instance()
        var _rs = plus.connect("pressed", self, "_on_Button_pressed")
        get_node(grant_background).add_child(plus)
        
        if not grant.is_available:
            plus.disabled = true
            plus.modulate = Color(1, 1, 1, 0.4)
            # TODO: add tooltip - why char is unavailable

        var amount_label = EffectLabel.instance()
        amount_label.text =  str(grant.amount) + " " + tr("GRANT_AMOUNT")
        amount_label.add_color_override("font_color", good_color)
        get_node(grant_labels_placeholder).add_child(amount_label)

        var diff_label = EffectLabel.instance()
        diff_label.text =  str(grant.difficulty) + " " + tr("GRANT_DIFFICULTY")
        diff_label.add_color_override("font_color", bad_color)
        get_node(grant_labels_placeholder).add_child(diff_label)

    elif is_current:
        var chance = GrantChance.instance()
        chance.get_node("ColorRect/Label").text = str(grant.chance) + "%"
        get_node(grant_add_info_path).add_child(chance)

        var diff_label = EffectLabel.instance()
        diff_label.text =  str(grant.difficulty) + " " + tr("GRANT_DIFFICULTY")
        diff_label.add_color_override("font_color", bad_color)
        get_node(grant_labels_placeholder).add_child(diff_label)

    elif is_completed:
        pass

