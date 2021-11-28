extends Node
class_name SimulationCore

var T = load("res://logic/simulation/Classes.gd")
var StorageT = load("res://logic/simulation/Storage.gd")
var Storage = StorageT.new()
var EngineT = load("res://logic/simulation/Engine.gd")
var Engine = EngineT.new()

signal update_log(logs)
signal characters_updated
signal grants_updated
signal faculty_updated(faculty_uid)
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
    elif arg3 == null:
        emit_signal(signal_name, arg1, arg2)
    else:
        emit_signal(signal_name, arg1, arg2, arg3)


func _ready():
    var emitter_ref = funcref(self, "emitter")
    Storage.emitter = emitter_ref
    Engine.Storage = Storage
    Engine.T = T
    Engine.emitter = emitter_ref

    Storage.load_resources()
    Storage.FACULTY_LIST[0].staff_uid_list.append(Storage.CHARACTER_LIST[0].uid)
    Engine.update_all()

    if utils.is_debug:
        var dt = get_grants_data()
        for obj in dt.available_grants:
            print_debug("Available: ", obj.name, " ", obj.level, " ", obj.is_available)
        for obj in dt.current_grants:
            print_debug("Current: ", obj.name)
        for obj in dt.completed_grants:
            print_debug("Completed: ", obj.name)

        for obj in Storage.EQUIPMENT_LIST:
            print_debug("EQ: ", obj.name, " ", obj.uid, " ", obj.price)

        for obj in Storage.FACULTY_LIST:
            print_debug(
                "FACULTY: ", obj.specialty_uid, " ", obj.icon_uid, " ", obj.default_cost, " ", obj.default_breakthrough_chance, " ",
                "breakthrough_chance: ", obj.breakthrough_chance, " ",
                "yearly_cost: ", obj.yearly_cost, " ",
                "level: ", obj.level, " ",
                "CHARS effects: ", obj.character_mods_abs, " ", obj.character_mods_rel, " ",
                "LEADER effects: ", obj.leader_mods_abs, " ", obj.leader_mods_rel, " ",
                "EQ effects: ", obj.equipment_mods_abs, " ", obj.equipment_mods_rel, " "
            )


func _process(_delta):
    pass


#####################################################################################
######################################## API ########################################
#####################################################################################


func start():
    emit_signal("money_updated", Storage.money, true)
    emit_signal("reputation_updated", Storage.reputation, true)
    emit_signal("date_updated", "December 3, 2021")  # TODO: actual date
    emit_signal("update_log", "START_LOG_")  # TODO: translate


func hire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if character.is_hired or not character.is_available:
        return
    if not Storage.spend_money(character.price):
        return
    character.is_hired = true
    emit_signal("characters_updated")


func fire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if not character.is_hired:
        return
    character.is_hired = false
    Engine.update_character(character)
    Storage.set_sim_state_of(T.Faculty, T.SimState.OUT_OF_SYNC)
    emit_signal("characters_updated")


func take_grant(grant_uid):
    var grant = Storage.get_grant(grant_uid)
    if not grant.is_available or grant.is_taken:
        return
    Storage.gain_money(grant.amount)
    grant.is_taken = true
    Engine.update_grant(grant)
    Engine.update_goals()
    emit_signal("grants_updated")


func get_characters_data():
    return T.CharactersData.new(
        Engine.get_characters_list(false),
        Engine.get_characters_list(true)
    )


func get_grants_data():
    return T.GrantsData.new(
        Engine.get_grants_list({
            "is_taken": true,
            "is_completed": false,
        }),
        Engine.get_grants_list({
            "is_taken": false
        }),
        Engine.get_grants_list({
            "is_completed": true,
        }),
        Engine.get_goals_list()
    )


func get_faculty_data(faculty_uid):
    return Engine.get_faculty_info(faculty_uid)
