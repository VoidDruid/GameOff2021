extends Node
class_name SimulationCore

var T = load("res://logic/simulation/Classes.gd")
var StorageT = load("res://logic/simulation/Storage.gd")
var Storage = StorageT.new()
var EngineT = load("res://logic/simulation/Engine.gd")
var Engine = EngineT.new()

enum UpdateType {FACULTY, GRANT, CHARACTER}

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

    # TODO: remove debug stuff
    if utils.is_debug:
        Storage.GRANT_LIST[0].is_taken = true
        Storage.GRANT_LIST[1].is_completed = true
        Storage.FACULTY_LIST[0].is_opened = true
        Storage.FACULTY_LIST[0].staff_uid_list.append(Storage.CHARACTER_LIST[2].uid)

    Engine.update_all()

    # TODO: remove debug stuff
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
                "chars: ", obj.staff_uid_list, " ",
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


func get_specialty_color(specialty_uid) -> Color:
    return Storage.get_specialty(specialty_uid).color


func remove_grant(faculty, update=true, allowed_updates=null):
    if faculty.grant_uid == null:
        return
    var prev_grant = Storage.get_grant(faculty.grant_uid)
    Storage.grant_to_faculty[faculty.grant_uid] = null
    prev_grant.is_in_progress = false
    prev_grant.chance = 0
    faculty.grant_uid = null

    if update:
        if allowed_updates == null or UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emit_signal("faculty_updated", faculty.uid)
        if allowed_updates == null or UpdateType.GRANT in allowed_updates:
            Engine.update_grant(prev_grant)
            emit_signal("grants_updated")


func unassign_grant(grant, update=true, allowed_updates=null):
    var prev_faculty_uid = Storage.grant_to_faculty[grant.uid]
    if prev_faculty_uid == null:
        return
    var prev_faculty = Storage.get_faculty(prev_faculty_uid)
    prev_faculty.grant_uid = null
    grant.chance = 0

    if update:
        if allowed_updates == null or UpdateType.GRANT in allowed_updates:
            Engine.update_grant(grant)
            emit_signal("grants_updated")
        if allowed_updates == null or UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(prev_faculty)
            emit_signal("faculty_updated", prev_faculty.uid)


func remove_character_from_work(character, update=true, allowed_updates=null):
    if character.faculty_uid == null:
        return

    var prev_faculty = Storage.get_faculty(character.faculty_uid)
    if prev_faculty.leader_uid == character.uid:
        prev_faculty.leader_uid = null
    else:
        prev_faculty.staff_uid_list.remove(prev_faculty.staff_uid_list.find(character.uid))

    character.faculty_uid = null

    if update and (allowed_updates == null or UpdateType.CHARACTER in allowed_updates):
        Engine.update_faculty(prev_faculty)
        emit_signal("faculty_updated", prev_faculty.uid)


func assign_leader(faculty_uid, character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    remove_character_from_work(character)

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.leader_uid = character_uid

    if update:
        if allowed_updates == null or UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emit_signal("characters_updated")
        if allowed_updates == null or UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emit_signal("faculty_updated", faculty_uid)


func assign_grant(faculty_uid, grant_uid):
    var grant = Storage.get_grant(grant_uid)
    unassign_grant(grant, true, [UpdateType.FACULTY])
    grant.is_in_progress = true

    var faculty = Storage.get_faculty(faculty_uid)
    remove_grant(faculty, false)
    faculty.grant_uid = grant_uid
    Storage.grant_to_faculty[grant_uid] = faculty_uid

    Engine.update_grant(grant)
    Engine.update_faculty(faculty)
    emit_signal("faculty_updated", faculty.uid)
    emit_signal("grants_updated")


func add_staff(faculty_uid, character_uid):
    var character = Storage.get_character(character_uid)
    remove_character_from_work(character)

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.staff_uid_list.append(character_uid)
    Engine.update_faculty(faculty)
    emit_signal("faculty_updated", faculty_uid)


func remove_staff(faculty_uid, character_uid):
    var character = Storage.get_character(character_uid)
    if character.faculty_uid != faculty_uid:
        utils.notify_error({
            "character_uid": character_uid,
            "faculty_uid": faculty_uid,
            "error": "Tried to remove staff from faculty, but character not working here!"
        })
        return
    remove_character_from_work(character)


func buy_equipment(faculty_uid, equipment_uid):
    var equipment = Storage.get_equipment(equipment_uid)
    if equipment.is_active:
        utils.notify_error({
            "equipment_uid": equipment_uid,
            "faculty_uid": faculty_uid,
            "error": "Tried to buy equipment, but it is already active!"
        })
        return
    if not Storage.spend_money(equipment.price):
        return
    equipment.is_active = true
    emit_signal("faculty_updated", faculty_uid)


func set_enrollee_count(faculty_uid, count):
    var faculty = Storage.get_faculty(faculty_uid)
    faculty.enrollee_count = count
    Engine.update_faculty(faculty)
    emit_signal("faculty_updated", faculty_uid)


func hire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if character.is_hired or not character.is_available:
        utils.notify_error({
            "character_uid": character_uid,
            "error": "Tried to hire character, that is either not available or already hired!"
        })
        return
    if not Storage.spend_money(character.price):
        return
    character.is_hired = true
    emit_signal("characters_updated")


func fire_character(character_uid):
    var character = Storage.get_character(character_uid)
    if not character.is_hired:
        utils.notify_error({
            "character_uid": character_uid,
            "error": "Tried to fire character, that is not hired!"
        })
        return
    remove_character_from_work(character)
    character.is_hired = false
    Engine.update_character(character)
    emit_signal("characters_updated")


func take_grant(grant_uid):
    var grant = Storage.get_grant(grant_uid)
    if not grant.is_available or grant.is_taken:
        utils.notify_error({
            "grant_uid": grant_uid,
            "error": "Tried to take grant, that is either not available or already taken!"
        })
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
