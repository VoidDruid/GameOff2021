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
var faculty_cost_label_path = faculty_cost_panel_path + "/Label"
var leader_name_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/LeaderName/Label"
var leader_effects_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Effects/HBoxContainer"
var faculty_grant_chance_tab_path = "HBoxContainer/TextureRectRight/Right/GrantChance"
var faculty_employees_sum_effect_label_path = "HBoxContainer/TextureRectRight/Right/TextureRect/VBoxHired/SummEffect/EffectLabel"
var enrolle_counter_path = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/SpinBox"
var cost_per_year_label = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/CostPerYear"

var equipment_list_path = "HBoxContainer/LeftTextureRect/Left/EquipmentList/TextureRect/VBoxContainer/List/ScrollContainer/VBoxContainer"


func _on_AddStaff_pressed():
    pass


func _on_GrantButton_pressed():
    #game_manager.on_GrButton_pressed(gr_id)
    pass

func _on_SpinBox_value_changed(value):
    game_manager.on_EnrolleeCount_changed(faculty.uid, value)


func _ready():
    if faculty.leader_uid != null:
        leader = simulation.get_character_data(faculty.leader_uid)

    get_node(enrollee_count_path).value = faculty.enrollee_count

    var _rs = get_node(grant_chance_button_path).connect("pressed", self, "_on_GrantButton_pressed")
    _rs = get_node(enrolle_counter_path).connect("value_changed", self, "_on_SpinBox_value_changed")

    var grant_tab_percent
    var grant_tab_description
    if faculty.grant_uid != null:
        grant_tab_percent = str(faculty.breakthrough_chance) + "%"
        grant_tab_description = simulation.get_grant_data(faculty.grant_uid).name
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
        leader_tab.get_node(leader_name_path).text = leader.name

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
        eq_tab.game_manager = self
        eq_tab.equipment = eq
        eq_tab.EffectLabel = game_manager.EffectLabel
        eq_tab.get_node("Background").color = game_manager.get_color_index(i)
        get_node("HBoxContainer/LeftTextureRect/Left/EquipmentList/TextureRect/VBoxContainer/List/ScrollContainer/VBoxContainer").add_child(eq_tab)
        i += 1
