extends Node
class_name GameManager

export(Color) var light_color
export(Color) var dark_light_color
export(Color) var default_log_color
export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color

export(NodePath) var simulation_node_path
var simulation: SimulationCore
var MainWindow: Control
var CurrentGameWindow
var FeedTable: Control
var MoneyCounter: Control
var ReputationCounter: Control
var DateCounter: Control
var FacultiesButton: TextureButton
var CharactersButton: TextureButton
var GrantsButton: TextureButton

enum {UNKNOWN_SCREEN, GRANTS_SCREEN, CHARACTERS_SCREEN, FACULTY_SCREEN}

enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE}

var CurrentScreen

var ui_res_folder = "res://objects/ui/"
var game_manager_path = @"/root/Main/UI/GameUI"

var pressed_texture_res = load(ui_res_folder + "overrides/pressed_button.svg")
var FeedTab_res = load(ui_res_folder + "FeedTab.tscn")
var FeedTabY_res = load(ui_res_folder + "FeedTabY.tscn")
var FeedTabB_res = load(ui_res_folder + "FeedTabB.tscn")
var GrantTab_res = load(ui_res_folder + "GrantTab.tscn")
var Grants_res = load(ui_res_folder + "Grants.tscn")
var Faculty_res = load(ui_res_folder + "Faculty.tscn")
var Characters_res = load(ui_res_folder + "Characters.tscn")
var ACharacterTab_res = load(ui_res_folder + "ACharacterTab.tscn")
var StaffTab_res = load(ui_res_folder + "StaffTab.tscn")
var FacultyTab_res = load(ui_res_folder + "FacultyTab.tscn")
var EffectLabel = load(ui_res_folder + "EffectLabel.tscn")
var PlusButton = load(ui_res_folder + "PlusTButton.tscn")
var GrantChance = load(ui_res_folder + "GrantChance.tscn")


func get_color_index(index) -> Color:
    return dark_light_color if index % 2 == 0 else light_color


func _ready():
    CurrentScreen = UNKNOWN_SCREEN
    simulation = get_node(simulation_node_path)
    MainWindow = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerRight/GameWindow")
    MoneyCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/StatusBar/Money")
    ReputationCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/StatusBar/Reputation")
    DateCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/Control")
    FeedTable = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/ScrollFeed/Feed/ScrollContainer/VBoxContainer")
    FacultiesButton = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerRight/Control/HBoxContainer/Faculties")
    CharactersButton = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerRight/Control/HBoxContainer/Characters")
    GrantsButton = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerRight/Control/HBoxContainer/Grants")
    
    var _rs = simulation.connect("characters_updated", self, "_on_Characters_update")
    _rs = simulation.connect("money_updated", self, "_on_Money_updated")
    _rs = simulation.connect("grants_updated", self, "_on_Grants_updated")
    _rs = simulation.connect("money_error", self, "_on_Money_error")
    _rs = simulation.connect("reputation_updated", self, "_on_Reputation_updated")
    _rs = simulation.connect("date_updated", self, "_on_Date_updated")
    _rs = simulation.connect("update_log", self, "_on_Update_log")
    _rs = simulation.connect("faculty_updated", self, "_on_Faculty_update")

    simulation.start()


func _process(_delta):
    pass

func on_Menu_button_pressed(is_ch, is_gr, is_fc):
    if is_ch:
        CharactersButton.set_normal_texture(pressed_texture_res)
        GrantsButton.set_normal_texture(null)
        FacultiesButton.set_normal_texture(null)
    elif is_gr:
        GrantsButton.set_normal_texture(pressed_texture_res)
        FacultiesButton.set_normal_texture(null)
        CharactersButton.set_normal_texture(null)
    elif is_fc:
        FacultiesButton.set_normal_texture(pressed_texture_res)
        GrantsButton.set_normal_texture(null)
        CharactersButton.set_normal_texture(null)

func _on_Characters_pressed():
    on_Menu_button_pressed(true, false, false)
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    CurrentScreen = CHARACTERS_SCREEN
    buildCharactersWindow()
    MainWindow.add_child(CurrentGameWindow)


func _on_Grants_pressed():
    on_Menu_button_pressed(false, true, false)
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    CurrentScreen = GRANTS_SCREEN
    buildGrantsWindow()
    MainWindow.add_child(CurrentGameWindow)


func _on_Faculties_pressed():
    on_Menu_button_pressed(false, false, true)
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    CurrentScreen = FACULTY_SCREEN
    var faculty_id = simulation.Storage.FACULTY_LIST[0].uid
    buildFacultyWindow(faculty_id)
    MainWindow.add_child(CurrentGameWindow)


var log_count = 0
func _on_Update_log(log_list):
    var tab
    var log_text
    var log_color = default_log_color
    if typeof(log_list) in [TYPE_STRING, TYPE_DICTIONARY]:
        log_list = [log_list]
    for log_ in log_list:
        match typeof(log_):
            TYPE_STRING:
                log_text = log_
            TYPE_DICTIONARY:
                log_text = log_["text"]
                log_color = log_.get_color("color", default_log_color)
                if typeof(log_color) != TYPE_COLOR:
                    log_color = Color(log_color)
            var err_type:
                utils.notify_error({
                    "log": log_,
                    "error": "Tried to process log of invalid type " + str(err_type)
                })
                continue
        tab = FeedTab_res.instance()
        tab.get_node("Panel").color = get_color_index(log_count)
        tab.get_node("Panel/LeftTabColor").color = log_color
        tab.get_node("Panel/RichTextLabel").text = log_text
        FeedTable.add_child(tab)
        log_count += 1

# enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE}
func on_ChButton_pressed(ch_id, f_id, action):
    print_debug("CALLED CH: ", ch_id, action)
    if action == CHARACTER_FIRE:
        simulation.actions.fire_character(ch_id)
    elif action == CHARACTER_HIRE:
        simulation.actions.hire_character(ch_id)
    elif action == STAFF_ADD:
        simulation.actions.add_staff(f_id, ch_id)
    elif action == STAFF_REMOVE:
        simulation.actions.remove_staff(f_id, ch_id)

func on_GrButton_pressed(gr_id):
    print_debug("CALLED GR: ", gr_id)
    simulation.actions.take_grant(gr_id)

func _on_Faculty_update(_faculty_uid):
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    CurrentScreen = FACULTY_SCREEN
    var faculty_id = simulation.Storage.FACULTY_LIST[0].uid
    buildFacultyWindow(faculty_id)
    MainWindow.add_child(CurrentGameWindow)

func _on_Grants_updated():
    if CurrentScreen != GRANTS_SCREEN:
        return
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    buildGrantsWindow()
    MainWindow.add_child(CurrentGameWindow)


func _on_Characters_update():
    if CurrentScreen != CHARACTERS_SCREEN:
        return
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    buildCharactersWindow()
    MainWindow.add_child(CurrentGameWindow)

func _on_Money_error():
    print_debug("MONEY ERROR")


func _on_Money_updated(amount, has_increased):
    print_debug(str(amount) + str(has_increased))
    MoneyCounter.get_node("TextureRect/Name").text = "MONEY_"
    MoneyCounter.get_node("TextureRect/Value").text = str(amount)


func _on_Reputation_updated(amount, has_increased):
    print_debug(str(amount) + str(has_increased))
    ReputationCounter.get_node("TextureRect/Name").text = "REPUTATION_"
    ReputationCounter.get_node("TextureRect/Value").text = str(amount)


func _on_Date_updated(date_string):
    print_debug(str(date_string))
    DateCounter.get_node("TextureRect/Label").text = str(date_string)

func buildGrantsWindow():
    CurrentGameWindow = Grants_res.instance()
    CurrentGameWindow.get_node("VBoxContainer/Grants/TextureRect/AvailableGrants/Control/Label").text = tr("GRANTS_AVAILABLE")
    CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/CurrentTextureRect/CurrentGrants/Control/Label").text = tr("GRANTS_CURRENT")
    CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/FinishedTextureRect/FinishedGrants/Control/Label").text = tr("GRANTS_FINISHED")

    var dt = simulation.get_grants_data()

    #build available grants
    var i = 0
    for gr in dt.available_grants:
        var grTab = GrantTab_res.instance()
        grTab.game_manager = self
        grTab.get_node("HBoxContainer/Background").color = get_color_index(i)
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, true, false, false)
        CurrentGameWindow.get_node("VBoxContainer/Grants/TextureRect/AvailableGrants/AvailableGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1

    #build current grants
    i = 0
    for gr in dt.current_grants:
        var grTab = GrantTab_res.instance()
        grTab.game_manager = self
        grTab.get_node("HBoxContainer/Background").color = get_color_index(i)
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, false, true, false)
        CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/CurrentTextureRect/CurrentGrants/CurrentGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1

    #build finished grants
    i = 0
    for gr in dt.completed_grants:
        var grTab = GrantTab_res.instance()
        grTab.game_manager = self
        grTab.get_node("HBoxContainer/Background").color = get_color_index(i)
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, false, false, true)
        CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/FinishedTextureRect/FinishedGrants/FinishedGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1


func buildCharactersWindow():
    CurrentGameWindow = Characters_res.instance()
    var dt = simulation.get_characters_data()

    # build available characters
    var i = 0
    for ch in dt.available_characters:
        var chTab = ACharacterTab_res.instance()
        chTab.game_manager = self
        chTab.EffectLabel = EffectLabel
        chTab.character = ch
        chTab.get_node("Background").color = get_color_index(i)
        CurrentGameWindow.get_node("Characters/Available/VBoxAvailable/Available/VBoxContainer").add_child(chTab)
        i += 1

    # build hired characters
    i = 0
    for ch in dt.hired_characters:
        var chTab = ACharacterTab_res.instance()
        chTab.game_manager = self
        chTab.EffectLabel = EffectLabel
        chTab.character = ch
        chTab.get_node("Background").color = get_color_index(i)
        CurrentGameWindow.get_node("Characters/Hired/VBoxHired/Hired/VBoxContainer").add_child(chTab)
        i += 1

func buildFacultyWindow(faculty_id):
    CurrentGameWindow = Faculty_res.instance()
    var faculty = simulation.get_faculty_data(faculty_id)
    # build grant panel
    var faculty_grant_chance_tab_path = "HBoxContainer/TextureRectRight/Right/GrantChance"
    var faculty_employees_sum_effect_label_path = "HBoxContainer/TextureRectRight/Right/TextureRect/VBoxHired/SummEffect/EffectLabel"

    var grant_tab_percent
    var grant_tab_description
    if faculty.grant_uid != null:
        grant_tab_percent = str(faculty.breakthrough_chance) + "%"
        grant_tab_description = tr("GRANT_") + "\n" + simulation.get_grant_data(faculty.grant_uid)
    else:
        grant_tab_percent = ""
        grant_tab_description = tr("GRANT_UNKNOWN")
    CurrentGameWindow.get_node(faculty_grant_chance_tab_path).get_node("TextureRectRight/GrantChancePanel/Percent").text = grant_tab_percent
    CurrentGameWindow.get_node(faculty_grant_chance_tab_path).get_node("TextureRectRight/GrantChancePanel/Description").text = grant_tab_description

    # build empoyees list
    CurrentGameWindow.get_node(faculty_employees_sum_effect_label_path).text = "25 " + tr("MOD_BREAKTHROUGH_CHANCE") #str(faculty.staff_effect) + " " + tr("MOD_BREAKTHROUGH_CHANCE")
    CurrentGameWindow.get_node(faculty_employees_sum_effect_label_path).add_color_override("font_color", good_color)

    var i = 0
    for ch_uid in faculty.staff_uid_list:
        var ch = simulation.get_character_data(ch_uid)
        var stTab = StaffTab_res.instance()
        stTab.game_manager = self
        stTab.character = ch
        stTab.get_node("Background").color = get_color_index(i)
        CurrentGameWindow.get_node("HBoxContainer/TextureRectRight/Right/TextureRect/VBoxHired/Employees/VBoxContainer").add_child(stTab)
        i += 1

    #build leader tab
    var facultyTab = FacultyTab_res.instance()
    facultyTab.game_manager = self
    facultyTab.EffectLabel = EffectLabel
    if faculty.leader_uid != null:
        facultyTab.leader = simulation.get_character_data(faculty.leader_uid)
    else:
        var leader = simulation.get_characters_data().hired_characters[0]
        facultyTab.leader = leader
    buildFacultyTab(facultyTab.leader)

func buildFacultyTab(leader):
    var curTab = CurrentGameWindow.get_node("HBoxContainer/LeftTextureRect/Left/FacultyTab")
    var leader_cost_panel_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Control/Panel"
    var leader_cost_label_path = leader_cost_panel_path + "/Label"
    var leader_name_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/LeaderName/Label"
    var leader_effects_path = "TextureRect/HBoxContainer/LeaderInfo/VBoxContainer/Effects/HBoxContainer"
    if leader != null:
        var leader_cost_label = curTab.get_node(leader_cost_label_path)
        leader_cost_label.text = ("   " +
            str(leader.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")
            + "   "
        )
        var cost_panel = curTab.get_node(leader_cost_panel_path)
        var panel_style = StyleBoxFlat.new()
        panel_style.set_corner_radius_all(5)
        panel_style.set_bg_color(hired_panel_color)
        cost_panel.set('custom_styles/panel', panel_style)
        yield(get_tree(), "idle_frame")
        cost_panel.rect_min_size.x = leader_cost_label.rect_size.x

        curTab.get_node(leader_name_path).text = leader.name

        var leader_effects = curTab.get_node(leader_effects_path)
        for modifier in leader.modifiers:
            var panel = Panel.new()
            var new_style = StyleBoxFlat.new()
            new_style.set_corner_radius_all(5)
            new_style.set_bg_color(good_color if modifier.positive else bad_color)
            panel.set('custom_styles/panel', new_style)

            var mod_label: Label = EffectLabel.instance()
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
            panel.rect_min_size.x = mod_label.rect_size.x
            panel.rect_min_size.y = mod_label.rect_size.y
    else:
        pass
