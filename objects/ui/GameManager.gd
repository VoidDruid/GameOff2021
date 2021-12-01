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
var FacultyMap: Control

enum {UNKNOWN_SCREEN, GRANTS_SCREEN, CHARACTERS_SCREEN, FACULTY_SCREEN}

enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE, LEADER_ASSIGN, FACULTY_ADD}

enum {TAKE_GRANT, ASSIGN_GRANT, WATCH_GRANT}

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
var ObjectDetail_res = load(ui_res_folder + "ObjectDetail.tscn")
var ObjectChoice_res = load(ui_res_folder + "ObjectChoice.tscn")
var Darkinator_res = load(ui_res_folder + "Darkinator3000.tscn")
var EquipmentTab_res = load(ui_res_folder + "EquipmentTab.tscn")
var GoalC_res = load(ui_res_folder + "GoalC.tscn")
var BuyButton_res = load(ui_res_folder + "BuyButton.tscn")
var BoughtButton_res = load(ui_res_folder + "BoughtButton.tscn")

var EffectLabel = load(ui_res_folder + "EffectLabel.tscn")
var PlusButton = load(ui_res_folder + "PlusTButton.tscn")
var TickButton = load(ui_res_folder + "TickButton.tscn")
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
    FacultyMap = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/Map")
    
    var _rs = simulation.connect("characters_updated", self, "_on_Characters_update")
    _rs = simulation.connect("money_updated", self, "_on_Money_updated")
    _rs = simulation.connect("grants_updated", self, "_on_Grants_updated")
    _rs = simulation.connect("money_error", self, "_on_Money_error")
    _rs = simulation.connect("reputation_updated", self, "_on_Reputation_updated")
    _rs = simulation.connect("date_updated", self, "_on_Date_updated")
    _rs = simulation.connect("update_log", self, "_on_Update_log")
    _rs = simulation.connect("faculty_updated", self, "_on_Faculty_update")
    
    FacultyMap.get_node("VBoxContainer/Control/Add").connect("pressed", self, "_on_AddFaculty_pressed")

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

# enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE, LEADER_ASSIGN}
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
    elif action == LEADER_ASSIGN:
        simulation.actions.assign_leader(f_id, ch_id)


func on_GrButton_pressed(gr_id, faculty_uid, action_type):
    print_debug("CALLED GR: ", gr_id, " ", faculty_uid, " ", action_type)
    match action_type:
        TAKE_GRANT:
            simulation.actions.take_grant(gr_id)
        ASSIGN_GRANT:
            simulation.actions.assign_grant(faculty_uid, gr_id)

func on_EqButton_pressed(faculty_uid, equipment_uid):
    simulation.actions.buy_equipment(faculty_uid, equipment_uid)

func on_EnrolleeCount_changed(faculty_uid, count):
    print_debug("on_EnrolleeCount_changed ", faculty_uid, count)
    simulation.actions.set_enrollee_count(faculty_uid, count)

func _on_Faculty_update(_faculty_uid):
    if CurrentScreen != FACULTY_SCREEN:
        return
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
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
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, TickButton, true, false, false)
        CurrentGameWindow.get_node("VBoxContainer/Grants/TextureRect/AvailableGrants/AvailableGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1

    #build current grants
    i = 0
    for gr in dt.current_grants:
        var grTab = GrantTab_res.instance()
        grTab.game_manager = self
        grTab.get_node("HBoxContainer/Background").color = get_color_index(i)
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, TickButton, false, true, false)
        CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/CurrentTextureRect/CurrentGrants/CurrentGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1

    #build finished grants
    i = 0
    for gr in dt.completed_grants:
        var grTab = GrantTab_res.instance()
        grTab.game_manager = self
        grTab.get_node("HBoxContainer/Background").color = get_color_index(i)
        grTab.setup_for_grant(gr, simulation.get_specialty_color(gr.specialty_uid), EffectLabel, PlusButton, GrantChance, TickButton, false, false, true)
        CurrentGameWindow.get_node("VBoxContainer/Grants/VBoxContainer/FinishedTextureRect/FinishedGrants/FinishedGrantsScroll/VBoxContainer").add_child(grTab)
        i += 1
    
    for goal in dt.goals:
        pass
        #var goal_c = GoalC_res.instance()
        


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
    CurrentGameWindow.faculty = faculty
    CurrentGameWindow.game_manager = self
    CurrentGameWindow.simulation = simulation
    
### faculties map

func _on_AddFaculty_pressed():
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)
    choice_dialog(1, darkinator, FACULTY_ADD)


func choice_dialog(object_type, darkinator, action_type=null):
    var choice_dialog_window = ObjectChoice_res.instance()
    choice_dialog_window.darkinator = darkinator
    choice_dialog_window.game_manager = self
    choice_dialog_window.object_type = object_type
    choice_dialog_window.parent_uid = "faculty.uid"
    choice_dialog_window.action_type = action_type
    get_node("/root/Main/UI").add_child(choice_dialog_window)
