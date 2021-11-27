extends Node
class_name SimulationCore

export var RANDOMIZATION_FOR_DEBUG = false
var T = load("res://logic/simulation/Classes.gd")
var StorageT = load("res://logic/simulation/Storage.gd")
var Storage = StorageT.new()
var EngineT = load("res://logic/simulation/Engine.gd")
var Engine = EngineT.new()

signal update_log(logs)
signal characters_updated
signal money_error
signal money_updated(amount, has_increased)
signal reputation_updated(amount, has_increased)
signal date_updated(date_string)


# NOTE: I know this is ugly, but is seems like the only way to do it
# There is no vararg in gdscript
func emitter(signal_name, arg1=null, arg2=null, arg3=null):
    if arg1 == null:
        emit_signal(signal_name)
    elif arg2 == null:
        emit_signal(signal_name, arg1)
    elif arg3 ==  null:
        emit_signal(signal_name, arg1, arg2)
    else:
        emit_signal(signal_name, arg1, arg2, arg3)


func _ready():
    Engine.Storage = Storage
    Engine.emitter = funcref(self, "emitter")
    Storage.load_resources()

    if utils.is_debug:
        var dt = get_characters_data()
        for character in dt.available_characters:
            print_debug("Available: ", character.name)
        for character in dt.hired_characters:
            print_debug("Hired: ", character.name)
        pass


func _process(_delta):
    pass


func spend_money(amount: int) -> bool:
    if Storage.spend_money(amount):
        emit_signal("money_updated", Storage.money, false)
        return true
    else:
        emit_signal("money_error")
        return false


#####################################################################################
######################################## API ########################################
#####################################################################################


func start():
    emit_signal("money_updated", Storage.money, true)
    emit_signal("reputation_updated", Storage.reputation, true)
    emit_signal("date_updated", "December 3, 2021")  # TODO: actual date
    emit_signal("update_log", "START_LOG_")  # TODO: translate


func get_characters_list(is_hired=false, for_faculty=null):
    if for_faculty != null and typeof(for_faculty) == TYPE_STRING:
        for_faculty = Storage.get_faculty(for_faculty)
    var update_dynamic = Storage.get_sim_state_of(T.Character)

    var fitting_characters = []

    for character in Storage.CHARACTER_LIST:
        if update_dynamic:
            Engine.update_character(character)
        if character.is_hired != is_hired:
            continue
        if for_faculty != null:
            if character.specialty_uid == for_faculty.specialty_uid:
                fitting_characters.append(character)
            else:
                continue
        fitting_characters.append(character)

    if update_dynamic:
        Storage.set_sim_state_of(T.Character, T.SimState.IN_SYNC)

    return fitting_characters


func hire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if character.is_hired or not character.is_available:
        return
    if not spend_money(character.price):
        return
    character.is_hired = true
    emit_signal("characters_updated")


func fire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if not character.is_hired:
        return
    character.is_hired = false
    Engine.update_character(character)
    emit_signal("characters_updated")


func get_characters_data():
    return T.CharactersData.new(
        get_characters_list(false),
        get_characters_list(true)
    )
