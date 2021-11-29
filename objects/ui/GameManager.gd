extends Node
class_name GameManager

export(Color) var light_color
export(Color) var dark_light_color
export(Color) var default_log_color

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

var CurrentScreen

var ui_res_folder = "res://objects/ui/"
var game_manager_path = @"/root/Main/UI/GameUI"

var pressed_texture_res = load(ui_res_folder + "overrides/pressed_button.svg")
var FeedTab_res = load(ui_res_folder + "FeedTab.tscn")
var FeedTabY_res = load(ui_res_folder + "FeedTabY.tscn")
var FeedTabB_res = load(ui_res_folder + "FeedTabB.tscn")
var GrantTab_res = load(ui_res_folder + "GrantTab.tscn")
var Grants_res = load(ui_res_folder + "Grants.tscn")
var Characters_res = load(ui_res_folder + "Characters.tscn")
var ACharacterTab_res = load(ui_res_folder + "ACharacterTab.tscn")
var HCharacterTab_res = load(ui_res_folder + "HCharacterTab.tscn")
var EffectLabel = load(ui_res_folder + "EffectLabel.tscn")
var PlusButton = load(ui_res_folder + "PlusButton.tscn")
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
  #  CurrentGameWindow = load(ui_res_folder + "Faculty.tscn").instance()
  #  MainWindow.add_child(CurrentGameWindow)


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
        tab = FeedTab_res.instance()
        tab.get_node("Panel").color = get_color_index(log_count)
        tab.get_node("Panel/LeftTabColor").color = log_color
        tab.get_node("Panel/RichTextLabel").text = log_text
        FeedTable.add_child(tab)
        log_count += 1


func _on_Faculty_pressed(_num):
    pass

func _on_First_pressed():
    _on_Faculty_pressed(1)


func _on_Second_pressed():
    _on_Faculty_pressed(2)


func _on_Third_pressed():
    _on_Faculty_pressed(3)


func _on_Fourth_pressed():
    _on_Faculty_pressed(4)


func _on_Fifth_pressed():
    _on_Faculty_pressed(5)


func on_ChButton_pressed(ch_id, is_hired):
    print_debug("CALLED: ", ch_id, is_hired)
    if is_hired:
        simulation.fire_character(ch_id)
    else:
        simulation.hire_character(ch_id)

func on_GrButton_pressed(gr_id):
    print_debug("CALLED: ", gr_id)
    simulation.take_grant(gr_id)


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
    MoneyCounter.get_node("TextureRect/Name").text = "Money"
    MoneyCounter.get_node("TextureRect/Value").text = str(amount)


func _on_Reputation_updated(amount, has_increased):
    print_debug(str(amount) + str(has_increased))
    ReputationCounter.get_node("TextureRect/Name").text = "Reputation"
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
        chTab.is_hired = false
        chTab.character = ch
        chTab.get_node("Background").color = get_color_index(i)
        CurrentGameWindow.get_node("Characters/Available/VBoxAvailable/Available/VBoxContainer").add_child(chTab)
        i += 1

    # build hired characters
    i = 0
    for ch in dt.hired_characters:
        var chTab = HCharacterTab_res.instance()
        chTab.game_manager = self
        chTab.EffectLabel = EffectLabel
        chTab.is_hired = true
        chTab.character = ch
        chTab.get_node("Background").color = get_color_index(i)
        CurrentGameWindow.get_node("Characters/Hired/VBoxHired/Hired/VBoxContainer").add_child(chTab)
        i += 1
