extends Control

export(Color) var good_color
export(Texture) var cross_texture

var faculty
var leader
var simulation: SimulationCore
var game_manager: GameManager

var grant_chance_button_path = "HBoxContainer/TextureRectRight/Right/GrantChance/Button"
var enrollee_count_path = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/SpinBox"
var leader_panel_path = "HBoxContainer/LeftTextureRect/Left/FacultyTab"
var faculty_cost_panel_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Control/Panel"
var faculty_name_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/FacultyName/Label"
var faculty_cost_label_path = faculty_cost_panel_path + "/Label"
var leader_name_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/LeaderName/Label"
var leader_effects_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Effects/HBoxContainer"
var leader_icon_path = "TextureRect/HBoxContainer/Leader/Icon/TextureRect"
var faculty_employees_sum_effect_label_path = "HBoxContainer/TextureRectRight/Right/TextureRect/VBoxHired/SummEffect/EffectLabel"
var enrolle_counter_path = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/SpinBox"
var cost_per_year_label = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/CostPerYear"

var faculty_grant_chance_tab_path = "HBoxContainer/TextureRectRight/Right/GrantChance"

var equipment_list_path = "HBoxContainer/LeftTextureRect/Left/EquipmentList/TextureRect/VBoxContainer/List/ScrollContainer/VBoxContainer"
onready var leader_button = $HBoxContainer/LeftTextureRect/Left/FacultyTab/TextureRect/HBoxContainer/Leader/Icon

func _on_AddStaff_pressed():
    var darkinator = game_manager.Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)
    choice_dialog(1, darkinator, game_manager.STAFF_ADD)


func choice_dialog(object_type, darkinator, action_type=null):
    var choice_dialog_window = game_manager.ObjectChoice_res.instance()
    choice_dialog_window.darkinator = darkinator
    choice_dialog_window.game_manager = game_manager
    choice_dialog_window.object_type = object_type
    choice_dialog_window.parent_uid = faculty.uid
    choice_dialog_window.action_type = action_type
    get_node("/root/Main/UI").add_child(choice_dialog_window)


func _on_GrantButton_pressed():
    var darkinator = game_manager.Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)

    var grant_choice = game_manager.ObjectDetail_res.instance()
    if faculty.grant_uid != null:
        grant_choice.grant = simulation.get_grant_data(faculty.grant_uid)
        grant_choice.darkinator = darkinator
        grant_choice.game_manager = game_manager
        grant_choice.object_type = 0
        grant_choice.parent_uid = faculty.uid
        get_node("/root/Main/UI").add_child(grant_choice)
    else:
        choice_dialog(0, darkinator)


func _on_LeaderButton_pressed():
    var darkinator = game_manager.Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)

    var leader_choice = game_manager.ObjectDetail_res.instance()
    if leader != null:
        leader_choice.character = leader
        leader_choice.darkinator = darkinator
        leader_choice.game_manager = game_manager
        leader_choice.object_type = 1
        leader_choice.parent_uid = faculty.uid
        get_node("/root/Main/UI").add_child(leader_choice)
    else:
        choice_dialog(1, darkinator)


func _on_SpinBox_value_changed(value):
    game_manager.on_EnrolleeCount_changed(faculty.uid, value)


func _ready():
    if faculty.leader_uid != null:
        leader = simulation.get_character_data(faculty.leader_uid)

    get_node(enrollee_count_path).value = faculty.enrollee_count

    var _rs = get_node(grant_chance_button_path).connect("pressed", self, "_on_GrantButton_pressed")
    _rs = get_node(enrolle_counter_path).connect("value_changed", self, "_on_SpinBox_value_changed")
    leader_button.connect("pressed", self, "_on_LeaderButton_pressed")

    var grant_tab_percent
    var grant_tab_description
    if faculty.grant_uid != null:
        grant_tab_percent = str(faculty.breakthrough_chance) + "%"
        var grant_f = simulation.get_grant_data(faculty.grant_uid)
        var years_text = ""
        if grant_f.is_taken:
            years_text += tr("YEARS_LEFT") + ": "
        else:
            years_text += tr("YEARS_GIVEN") + ": "
        years_text += str(grant_f.years_left) + " "
        if grant_f.years_left == 1:
            years_text += tr("YEAR")
        elif grant_f.years_left < 5:
            years_text += tr("YEARS_L5")
        else:
            years_text += tr("YEARS_GE5")
        grant_tab_description = grant_f.name + "\n" + years_text
    else:
        grant_tab_percent = ""
        grant_tab_description = tr("GRANT_UNKNOWN")

    get_node(cost_per_year_label).text = str(faculty.enrollee_cost) + " / " + tr("ENROLLEE_COST_")

    get_node(faculty_grant_chance_tab_path + "/Button/GrantChancePanel/Percent").text = grant_tab_percent
    get_node(faculty_grant_chance_tab_path + "/Button/GrantChancePanel/Description").text = grant_tab_description

    # build empoyees list
    get_node(faculty_employees_sum_effect_label_path).text = "25 " + tr("MOD_BREAKTHROUGH_CHANCE") #str(faculty.staff_effect) + " " + tr("MOD_BREAKTHROUGH_CHANCE")
    get_node(faculty_employees_sum_effect_label_path).add_color_override("font_color", good_color)

    var i = 0
    for ch_uid in faculty.staff_uid_list:
        var ch = simulation.get_character_data(ch_uid)
        var stTab = game_manager.StaffTab_res.instance()
        stTab.game_manager = game_manager
        stTab.character = ch
        stTab.get_node("Background").color = game_manager.get_color_index(i)
        get_node("HBoxContainer/TextureRectRight/Right/TextureRect/VBoxHired/Employees/VBoxContainer").add_child(stTab)
        i += 1

    var leader_tab = get_node(leader_panel_path)
    var faculty_cost_label = leader_tab.get_node(faculty_cost_label_path)
    leader_tab.get_node(faculty_name_path).text = faculty.name
    faculty_cost_label.text = ("   " +
        str(faculty.yearly_cost) + " " + tr("FACULTY_COST_PER_YEAR_")
        + "   "
    )
    var cost_panel = leader_tab.get_node(faculty_cost_panel_path)
    var panel_style = StyleBoxFlat.new()
    panel_style.set_corner_radius_all(5)
    panel_style.set_bg_color(game_manager.hired_panel_color)
    cost_panel.set('custom_styles/panel', panel_style)
    yield(get_tree(), "idle_frame")
    cost_panel.rect_min_size.x = faculty_cost_label.rect_size.x

    if leader != null:
        var leader_icon = leader_tab.get_node(leader_icon_path)
        if leader.icon_uid != null:
            var icon_res = utils.load_icon(leader.icon_uid)
            if icon_res != null:
                leader_icon.texture = icon_res
                leader_icon.rect_size.x = 256
                leader_icon.rect_size.y = 256
        var leader_name_l = leader_tab.get_node(leader_name_path)
        leader_name_l.text = tr("FACULTY_LEADER") + ": " + tr(leader.name) + ", " + tr(leader.title)
        leader_name_l.hint_tooltip = tr(leader.specialty_uid)

        var leader_effects = leader_tab.get_node(leader_effects_path)
        for modifier in leader.modifiers:
            var panel = Panel.new()
            var new_style = StyleBoxFlat.new()
            new_style.set_corner_radius_all(5)
            new_style.set_bg_color(game_manager.good_color if modifier.positive else game_manager.bad_color)
            panel.set('custom_styles/panel', new_style)

            var mod_label: Label = game_manager.EffectLabel.instance()
            var mod_text = "+" if modifier.value > 0 else ""
            mod_text += str(modifier.value if modifier.absolute else int(modifier.value * 100))
            mod_text += "%" if not modifier.absolute else ""
            mod_text += " " + tr("MOD_" + modifier.property.to_upper())
            mod_label.text = "   " + mod_text + "   "

            panel.add_child(mod_label)
            mod_label.align = Label.ALIGN_CENTER
            mod_label.valign = Label.ALIGN_CENTER
            leader_effects.add_child(panel)

            yield(get_tree(), "idle_frame")
            panel.size_flags_vertical = SIZE_SHRINK_END
            panel.rect_min_size.x = mod_label.rect_size.x
            panel.rect_min_size.y = mod_label.rect_size.y
    else:
        pass

    #build equipment list
    # equipment_list_path
    i = 0
    for eq_uid in faculty.equipment_uid_list:
        var eq = simulation.get_equipment_data(eq_uid)
        print(eq)
        var eq_tab = game_manager.EquipmentTab_res.instance()
        eq_tab.game_manager = game_manager
        eq_tab.equipment = eq
        eq_tab.faculty_uid = faculty.uid
        eq_tab.EffectLabel = game_manager.EffectLabel
        eq_tab.get_node("Background").color = game_manager.get_color_index(i)
        get_node("HBoxContainer/LeftTextureRect/Left/EquipmentList/TextureRect/VBoxContainer/List/ScrollContainer/VBoxContainer").add_child(eq_tab)
        i += 1
