extends Node
class_name GameManager

export(Color) var light_color
export(Color) var dark_light_color
export(Color) var default_log_color
export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color

export(AudioStreamMP3) var click_sound
export(AudioStreamMP3) var clock_sound
export(AudioStreamMP3) var failure_sound
export(AudioStreamMP3) var important_sound
export(AudioStreamMP3) var notification_sound
export(AudioStreamMP3) var success_sound
export(AudioStreamMP3) var tab_click_sound

export(NodePath) var simulation_node_path
export(NodePath) var ui_player_path = "/root/Main/UIPlayer"
export(NodePath) var effect_player_path = "/root/Main/EffectPlayer"

onready var ui_player: AudioStreamPlayer = get_node(ui_player_path)
onready var effect_player: AudioStreamPlayer = get_node(effect_player_path)
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
var ui_blocker = null

enum {UNKNOWN_SCREEN, GRANTS_SCREEN, CHARACTERS_SCREEN, FACULTY_SCREEN}

enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE, LEADER_ASSIGN, FACULTY_ADD}

enum {TAKE_GRANT, ASSIGN_GRANT, WATCH_GRANT}

var CurrentScreen
var is_year_running = false
var current_faculty_uid = null

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
var BuyButton_res = load(ui_res_folder + "BuyButton.tscn")
var BoughtButton_res = load(ui_res_folder + "BoughtButton.tscn")
var FacultyMapTab_res = load(ui_res_folder + "FacultyMapTab.tscn")
var UIBlocker_res = load(ui_res_folder + "UIBlocker.tscn")
var HelpHolder_res = load(ui_res_folder + "HelpHolder.tscn")
var GameOver_res = load(ui_res_folder + "GameOver.tscn")
var Event_res = load(ui_res_folder + "Event.tscn")

var EffectLabel = load(ui_res_folder + "EffectLabel.tscn")
var PlusButton = load(ui_res_folder + "PlusTButton.tscn")
var TickButton = load(ui_res_folder + "TickButton.tscn")
var GrantChance = load(ui_res_folder + "GrantChance.tscn")

var GoalBlue_res = load(ui_res_folder + "GoalBlue.tscn")
var GoalYellow_res = load(ui_res_folder + "GoalYellow.tscn")
var GoalRed_res = load(ui_res_folder + "GoalRed.tscn")
var GoalTeal_res = load(ui_res_folder + "GoalTeal.tscn")
var GOAL_RES = [GoalBlue_res, GoalRed_res, GoalTeal_res, GoalYellow_res]

onready var start_year_button = $__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/HBoxContainer/StartButton
onready var game_help_button = $__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/HBoxContainer/HelpButton
onready var campus_level_label = $__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainerLeft/LevelControl/TextureRect/Label


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
    _rs = simulation.connect("year_end", self, "_on_Year_end")
    _rs = simulation.connect("faculties_updated",self, "_on_Faculties_update")
    _rs = simulation.connect("game_over",self, "_on_GameOver")
    _rs = simulation.connect("victory",self, "_on_Victory")
    _rs = simulation.connect("campus_level_updated", self, "_on_CampusLevel_updated")
    _rs = simulation.connect("event", self, "_on_Event")

    _rs = start_year_button.connect("pressed", self, "_on_StartYear_pressed")
    _rs = game_help_button.connect("pressed", self, "_on_ShowHelp_pressed")

    _rs = FacultyMap.get_node("VBoxContainer/Control/Add").connect("pressed", self, "_on_AddFaculty_pressed")

    yield(get_tree(), "idle_frame")
    
    var failure_notice_ref = funcref(self, "play_failure_sound")
    var success_notice_ref = funcref(self, "play_success_sound")
    var important_notice_ref = funcref(self, "play_important_sound")
    simulation.failure_notice_ref = failure_notice_ref
    simulation.success_notice_ref = success_notice_ref
    simulation.important_notice_ref = important_notice_ref
    simulation.start()


func continue_year():
    play_clock_sound(1.7, 5)


func _on_Event(event_data):
    reset_effect_sound()
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)

    var event_panel = Event_res.instance()
    event_panel.darkinator = darkinator
    event_panel.event = event_data
    event_panel.continue_game_manager = funcref(self, "continue_year")
    event_panel.simulation = simulation
    get_node("/root/Main/UI").add_child(event_panel)


func play_ui_sound(sound):
    if ui_player.playing:
        if not (sound == failure_sound or sound == success_sound):
            return
    ui_player.volume_db = 0
    ui_player.stream = sound
    ui_player.playing = true


func play_tab_click():
    play_ui_sound(tab_click_sound)
    ui_player.volume_db = -4


func play_button_click():
    play_ui_sound(click_sound)


func play_failure_sound():
    play_ui_sound(failure_sound)


func play_success_sound():
    play_ui_sound(success_sound)


func play_important_sound():
    play_ui_sound(important_sound)
    ui_player.volume_db = -6


func play_notification_sound():
    play_ui_sound(notification_sound)


func play_clock_sound(pitch_scale=1, volume_db=0):
    effect_player.pitch_scale = pitch_scale
    effect_player.volume_db = volume_db
    effect_player.stream = clock_sound
    effect_player.playing = true


func reset_effect_sound():
    effect_player.playing = false
    effect_player.pitch_scale = 1
    effect_player.volume_db = 0


func _on_CampusLevel_updated(level):
    campus_level_label.text = tr("CAMPUS_LEVEL") + ": " + utils.to_roman(level)


func _on_Year_end():
    reset_effect_sound()
    is_year_running = false
    if ui_blocker != null:
        ui_blocker.queue_free()


func _on_StartYear_pressed():
    play_important_sound()
    play_clock_sound(1.7, 5)
    is_year_running = true
    ui_blocker = UIBlocker_res.instance()
    get_node("/root/Main/UI").add_child(ui_blocker)
    simulation.start_year()


func on_Menu_button_pressed(is_ch, is_gr, is_fc):
    play_tab_click()
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


func on_Faculty_pressed(uid):
    current_faculty_uid = uid
    _on_Faculties_pressed()


func _on_Faculties_pressed():
    if current_faculty_uid == null:
        return
    on_Menu_button_pressed(false, false, true)
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    CurrentScreen = FACULTY_SCREEN
    buildFacultyWindow(current_faculty_uid)
    MainWindow.add_child(CurrentGameWindow)


var log_count = 0
func _on_Update_log(log_list):
    play_notification_sound()
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
        FeedTable.move_child(tab, 0)
        log_count += 1

# enum {CHARACTER_FIRE, CHARACTER_HIRE, STAFF_ADD, STAFF_REMOVE, LEADER_ASSIGN}
func on_ChButton_pressed(ch_id, f_id, action):
    play_button_click()
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
    play_button_click()
    print_debug("CALLED GR: ", gr_id, " ", faculty_uid, " ", action_type)
    match action_type:
        TAKE_GRANT:
            simulation.actions.take_grant(gr_id)
        ASSIGN_GRANT:
            simulation.actions.assign_grant(faculty_uid, gr_id)

func on_FcButton_pressed(faculty_uid, action_type):
    play_button_click()
    print_debug("CALLED FC: ", faculty_uid, " ", action_type)
    match action_type:
        FACULTY_ADD:
            simulation.actions.open_faculty(faculty_uid)

func on_EqButton_pressed(faculty_uid, equipment_uid):
    simulation.actions.buy_equipment(faculty_uid, equipment_uid)

func on_EnrolleeCount_changed(faculty_uid, count):
    play_button_click()
    print_debug("on_EnrolleeCount_changed ", faculty_uid, count)
    simulation.actions.set_enrollee_count(faculty_uid, count)

func _on_Faculty_update(_faculty_uid):
    if CurrentScreen != FACULTY_SCREEN:
        return
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
        CurrentGameWindow = null
    buildFacultyWindow(_faculty_uid)
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
    MoneyCounter.get_node("TextureRect/Name").text = "MONEY_"
    MoneyCounter.get_node("TextureRect/Value").text = str(amount)


func _on_Reputation_updated(amount, has_increased):
    ReputationCounter.get_node("TextureRect/Name").text = "REPUTATION_"
    ReputationCounter.get_node("TextureRect/Value").text = str(amount)


func _on_Date_updated(date_string):
    DateCounter.get_node("TextureRect/Label").text = str(date_string)

func _on_Faculties_update():
    buildFacultiesMap()

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

    var goal_row = CurrentGameWindow.get_node("VBoxContainer/Goals")
    var ind = 0
    for goal in dt.goals:
        var goal_c = GOAL_RES[ind].instance()
        var name_b = goal_c.get_node("Name")
        goal_row.add_child(goal_c)
        name_b.text = goal.name
        var short_d = tr("SHORT_" + goal.description)
        if short_d != "SHORT_" + goal.description:
            name_b.hint_tooltip = short_d
        goal_c.value = goal.progress
        name_b.connect("pressed", self, "_on_Goal_pressed", [goal.uid])
        ind += 1


func _on_Goal_pressed(goal_uid):
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)

    var goal_detail = ObjectDetail_res.instance()
    goal_detail.goal = simulation.get_goal_data(goal_uid)
    goal_detail.darkinator = darkinator
    goal_detail.game_manager = self
    goal_detail.object_type = 2
    goal_detail.is_changable = false
    get_node("/root/Main/UI").add_child(goal_detail)


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

func buildFacultiesMap():
    var faculty_vbox = FacultyMap.get_node("VBoxContainer/Scroll/VBoxContainer")
    for n in faculty_vbox.get_children():
        faculty_vbox.remove_child(n)
        n.queue_free()
    var faculties = simulation.get_faculties()
    var i = 0
    for fc in faculties:
        if fc.is_opened:
            var fcTab = FacultyMapTab_res.instance()
            fcTab.game_manager = self
            fcTab.get_node("HBoxContainer/Background").color = get_color_index(i)
            fcTab.action_type = null
            fcTab.setup_for_faculty_map_tab(fc, simulation.get_specialty_color(fc.specialty_uid), EffectLabel, PlusButton, GrantChance, TickButton)
            faculty_vbox.add_child(fcTab)


func _on_AddFaculty_pressed():
    play_tab_click()
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)
    choice_dialog(2, darkinator, FACULTY_ADD)


func choice_dialog(object_type, darkinator, action_type=null):
    var choice_dialog_window = ObjectChoice_res.instance()
    choice_dialog_window.darkinator = darkinator
    choice_dialog_window.game_manager = self
    choice_dialog_window.object_type = object_type
    choice_dialog_window.parent_uid = 0
    choice_dialog_window.action_type = action_type
    get_node("/root/Main/UI").add_child(choice_dialog_window)


func _on_ShowHelp_pressed():
    play_tab_click()
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)
    choice_dialog(3, darkinator)


class GameOver:
    static func get_name():
        return "class_GameOver"

    var name
    var description

    func _init(name_, goal_name_):
        name = name_
        description = goal_name_


func buildGameOverTab(info):
    var darkinator = Darkinator_res.instance()
    get_node("/root/Main/UI").add_child(darkinator)
    var gameover_choice = ObjectDetail_res.instance()
    gameover_choice.game_over = info
    gameover_choice.darkinator = darkinator
    gameover_choice.game_manager = self
    gameover_choice.object_type = 3
    get_node("/root/Main/UI").add_child(gameover_choice)

func _on_GameOver():
    play_failure_sound()
    buildGameOverTab(GameOver.new("GAME_OVER_", "GAME_OVER_DESC_"))


func _on_Victory(goal_uid):
    play_success_sound()
    var goal = simulation.get_goal_data(goal_uid)
    buildGameOverTab(GameOver.new("WIN_", tr("COMPLETED_GOAL_") + " " + tr(goal.name) + ": " + tr(goal.description)))
