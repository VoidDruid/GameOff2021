extends Node
class_name SimulationCore

var failure_notice_ref: FuncRef
var success_notice_ref: FuncRef
var important_notice_ref: FuncRef

var T = load("res://logic/simulation/Classes.gd")
var StorageT = load("res://logic/simulation/Storage.gd")
var Storage = StorageT.new()
var EngineT = load("res://logic/simulation/Engine.gd")
var Engine = EngineT.new()
var ActionsT = load("res://logic/simulation/Actions.gd")
var Actions = ActionsT.new()

signal update_log(logs)
signal characters_updated
signal grants_updated
signal faculties_updated
signal goals_updated
signal faculty_updated(faculty_uid)
signal money_error
signal money_updated(amount, has_increased)
signal reputation_updated(amount, has_increased)
signal date_updated(date_string)
signal campus_level_updated(level)
signal event(event_data)
signal year_end

signal game_over
signal victory(goal_uid)


# NOTE: I know this is ugly, but is seems like the only way to do it
# There is no vararg in gdscript
func emitter(signal_name, arg1=null, arg2=null, arg3=null):
    if signal_name.begins_with("grant") and signal_name.ends_with("updated"):
        Engine.update_goals()

    # single update is not implemented for grant, character
    match signal_name:
        "grant_updated":
            signal_name = "grants_updated"
            arg1 = null
        "character_updated":
            signal_name = "characters_updated"
            arg1 = null

    # TODO: update signals bufferring
    # (add to buffer and emit only unique at start of new frame?)
    if arg1 == null:
        emit_signal(signal_name)
    elif arg2 == null:
        emit_signal(signal_name, arg1)
    elif arg3 == null:
        emit_signal(signal_name, arg1, arg2)
    else:
        emit_signal(signal_name, arg1, arg2, arg3)


func _ready():
    var _rs = connect("money_updated", self, "check_money")
    _rs = connect("reputation_updated", self, "check_reputation")

    var emitter_ref = funcref(self, "emitter")
    var logger_ref = funcref(self, "logger")

    Storage.emitter = emitter_ref
    Engine.Storage = Storage
    Engine.T = T
    Engine.emitter = emitter_ref
    Engine.logger = logger_ref

    Actions.Engine = Engine
    Actions.Storage = Storage
    Actions.T = T
    Actions.emitter = emitter_ref
    Actions.logger = logger_ref

    Storage.load_resources()

    Engine.update_all()


func _process(_delta):
    pass


func check_money(amount, _has_increased):
    if amount < 0:
        emit_signal("game_over")


func check_reputation(amount, _has_increased):
    if amount <= 0:
        emit_signal("game_over")


func logger(message, chance=1):
    if utils.with_chance(chance):
        emit_signal("update_log", message)


#####################################################################################
##################################### Public API ####################################
#####################################################################################

var actions = Actions

func start():
    emit_signal("faculties_updated")
    emit_signal("money_updated", Storage.money, true)
    emit_signal("reputation_updated", Storage.reputation, true)
    emit_signal("date_updated", Storage.format_date(Storage.datetime))
    emit_signal("update_log", tr("START_LOG_"))
    emit_signal("campus_level_updated", Storage.campus_level)
    Actions.failure_notice_ref = failure_notice_ref
    Actions.success_notice_ref = success_notice_ref
    Actions.important_notice_ref = important_notice_ref


func get_specialty_color(specialty_uid) -> Color:
    return Storage.get_specialty(specialty_uid).color


func get_characters_data():
    return T.CharactersData.new(
        Engine.get_characters_list(false),
        Engine.get_characters_list(true)
    )


func get_grant_data(grant_uid):
    var grant = Storage.get_grant(grant_uid)
    if not Storage.get_sim_state_of(T.Grant):
        Engine.update_grant(grant)
    return grant


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


func get_goal_data(goal_uid):
    var goal = Storage.get_goal(goal_uid)
    if not Storage.get_sim_state_of(T.Goal):
        Engine.update_goal(goal)
    return goal


func get_character_data(character_uid):
    var character = Storage.get_character(character_uid)
    if not Storage.get_sim_state_of(T.Character):
        Engine.update_character(character)
    return character


func get_equipment_data(equipment_uid):
    return Storage.get_equipment(equipment_uid)


func get_faculties():
    if not Storage.get_sim_state_of(T.Faculty):
        Engine.update_faculties()
    return Storage.FACULTY_LIST


func start_year():
    var month_delay = 0.2
    while true:
        if Actions.step_month():
            while true:
                yield(get_tree().create_timer(0.05), "timeout")
                if not Storage.is_event_active:
                    break

        if Storage.datetime["month"] == 8:
            break
        yield(get_tree().create_timer(month_delay), "timeout")

    Actions.decrement_years_on_grants()
    Actions.substract_characters_cost()
    Actions.substract_faculties_cost()

    if Storage.money < 900:
        logger(tr("LOW_MONEY_LOG"), 0.8)

    emit_signal("year_end")


func gain_money(amount: int) -> bool:
    return Storage.gain_money(amount)


func change_reputation(amount: int) -> bool:
    return Storage.change_reputation(amount)
