extends Node
class_name GameManager

export(NodePath) var simulation_node_path
var simulation: SimulationCore
var MainWindow: Control
var CurrentGameWindow
var LogTabText: RichTextLabel
var MoneyCounter: Control
var ReputationCounter: Control
var DateCounter: Control

enum {UNKNOWN_SCREEN, GRANTS_SCREEN, CHARACTERS_SCREEN, FACULTY_SCREEN}

var CurrentScreen

var ui_res_folder = "res://objects/ui/"
var game_manager_path = @"/root/Main/UI/GameUI"

func _ready():
    pass
    #CurrentScreen = UNKNOWN_SCREEN
    #simulation = get_node(simulation_node_path)
    #MainWindow = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/MainWindow")
    #LogTabText = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/HBoxContainer/VBoxContainer/Logs/Text")
    #MoneyCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/StatusBar/Counters/MoneyCounter")
    #ReputationCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/StatusBar/Counters/ReputationCounter")
   # DateCounter = get_node("__FullWindowBox__/FullWindowPanel/FullWindowBox/StatusBar/Counters/DateCounter")

    #var _rs = simulation.connect("update_log", self, "_on_Update_log")
    #_rs = simulation.connect("characters_updated", self, "_on_Characters_update")
    #_rs = simulation.connect("money_error", self, "_on_Money_error")
   # _rs = simulation.connect("money_updated", self, "_on_Money_updated")
   # _rs = simulation.connect("reputation_updated", self, "_on_Reputation_updated")
   # _rs = simulation.connect("date_updated", self, "_on_Date_updated")
    
  #  simulation.start()


func _process(_delta):
    pass


func _on_Characters_pressed():
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
    CurrentScreen = CHARACTERS_SCREEN
    buildCharactersWindow()
    MainWindow.add_child(CurrentGameWindow)



func _on_Grants_pressed():
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
    CurrentScreen = GRANTS_SCREEN
    buildGrantsWindow()
    MainWindow.add_child(CurrentGameWindow)


func _on_Faculty_pressed(_num):
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
    CurrentScreen = FACULTY_SCREEN
    CurrentGameWindow = load(ui_res_folder + "Faculty.tscn").instance()
    MainWindow.add_child(CurrentGameWindow)

func _on_Update_log(log_list):
    for log_ in log_list:
        LogTabText.add_text(log_ + "\n")


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


func on_ChButton_pressed(ch_id, is_hire):
    if is_hire:
        simulation.hire_character(ch_id)
    else:
        simulation.fire_character(ch_id)

func _on_Characters_update():
    if CurrentScreen != CHARACTERS_SCREEN:
        return
    if CurrentGameWindow != null:
        CurrentGameWindow.queue_free()
    buildCharactersWindow()
    MainWindow.add_child(CurrentGameWindow)

func _on_Money_error():
    print_debug("MONEY ERROR")


func _on_Money_updated(amount, has_increased):
    print_debug(str(amount) + str(has_increased))
    MoneyCounter.get_node("Background/Name").text = "Money"
    MoneyCounter.get_node("Background/Number").text = str(amount)


func _on_Reputation_updated(amount, has_increased):
    print_debug(str(amount) + str(has_increased))
    ReputationCounter.get_node("Background/Name").text = "Reputation"
    ReputationCounter.get_node("Background/Number").text = str(amount)


func _on_Date_updated(date_string):
    print_debug(str(date_string))
    DateCounter.get_node("Background/Name").text = str(date_string)

func buildGrantsWindow():
    CurrentGameWindow = load(ui_res_folder + "Grants.tscn").instance()
    CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/AvailableGrants/Label").text = "Available Grants"
    CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/VBoxContainer/CurrentGrantsLabel").text = "Current Grants"
    CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/VBoxContainer/FinishedGrantsLabel").text = "Finished Grants"

    var dt = simulation.get_characters_data()
    # available grants
    for gr in dt.available_characters:
        var grTab = load(ui_res_folder + "GrantTab.tscn").instance()
        grTab.get_node("Info").text = gr.name + " price: " + str(gr.price)
        grTab.get_node("Button").text = "Hire"
        grTab.grant_uid = gr.uid
        grTab.game_manager_path = game_manager_path
        #grTab.character_is_hire = true;
        if !gr.is_available:
            grTab.get_node("Button").hide()
        CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/AvailableGrants/AvailableGrantsScroll/VBoxContainer").add_child(grTab)

    # current grants
    for gr in dt.available_characters:
        var grTab = load(ui_res_folder + "GrantTab.tscn").instance()
        grTab.get_node("Info").text = gr.name + " price: " + str(gr.price)
        grTab.get_node("Button").text = "Hire"
        grTab.grant_uid = gr.uid
        grTab.game_manager_path = game_manager_path
        #grTab.character_is_hire = true;
        if !gr.is_available:
            grTab.get_node("Button").hide()
        CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/VBoxContainer/CurrentGrants/VBoxContainer").add_child(grTab)

    # finished grants
    for gr in dt.available_characters:
        var grTab = load(ui_res_folder + "GrantTab.tscn").instance()
        grTab.get_node("Info").text = gr.name + " price: " + str(gr.price)
        grTab.get_node("Button").text = "Hire"
        grTab.grant_uid = gr.uid
        grTab.game_manager_path = game_manager_path
        #grTab.character_is_hire = true;
        if !gr.is_available:
            grTab.get_node("Button").hide()
        CurrentGameWindow.get_node("VBoxContainer/HBoxContainer/VBoxContainer/FinishedGrants/VBoxContainer").add_child(grTab)

            

func buildCharactersWindow():
    CurrentGameWindow = load(ui_res_folder + "Characters.tscn").instance()
    CurrentGameWindow.get_node("Characters/VBoxAvailable/Label").text = "Available Characters"
    CurrentGameWindow.get_node("Characters/VBoxHired/Label").text = "Hired Characters"
    var dt = simulation.get_characters_data()

    # build available characters
    for ch in dt.available_characters:
        var chTab = load(ui_res_folder + "CharacterTab.tscn").instance()
        chTab.get_node("Info").text = ch.name + " price: " + str(ch.price)
        chTab.get_node("Button").text = "Hire"
        chTab.character_uid = ch.uid
        chTab.game_manager_path = game_manager_path
        chTab.character_is_hire = true;
        if !ch.is_available:
            chTab.get_node("Button").hide()
        CurrentGameWindow.get_node("Characters/VBoxAvailable/Available/VBoxContainer").add_child(chTab)

    # build hired characters
    for ch in dt.hired_characters:
        var chTab = load(ui_res_folder + "CharacterTab.tscn").instance()
        chTab.get_node("Info").text = ch.name + " price: " + str(ch.price)
        chTab.get_node("Button").text = "Fire"
        chTab.character_uid = ch.uid
        chTab.game_manager_path = game_manager_path
        chTab.character_is_hire = false;
        CurrentGameWindow.get_node("Characters/VBoxHired/Hired/VBoxContainer").add_child(chTab)
