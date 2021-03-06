var campus_level = 1
var money = 3500
var reputation = 100
var datetime = {
    "month": 8,
    "year": 2021,
}
var is_event_active = false
var grant_limit = 1
var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

var OBJECT_DATA_DIR = "res://gamedata/objects/"

var T = load("res://logic/simulation/Classes.gd")
var emitter = null
define(`object_store', `#NOTE: upcase($2)
var upcase($1)_LIST = []
var upcase($1)_MAP = {}
var _is_$1_updated = T.SimState.OUT_OF_SYNC


func get_$1($1_uid):
    return upcase($1)_MAP[$1_uid]


func _find_in_$1_list($1):
    var i = 0
    var uid
    if typeof($1) == TYPE_STRING:
        uid = $1
    else:
        uid = $1.uid
    for obj in upcase($1)_LIST:
        if obj.uid == uid:
            return i
        i += 1
    return null


func add_$1($1, skip_check=false):
    if not skip_check:
        var index = _find_in_$1_list($1)
        if index != null:
            upcase($1)_LIST.remove(index)
    upcase($1)_LIST.append($1)
    upcase($1)_MAP[$1.uid] = $1
')dnl
define(`simple_sync_get', `typename(capitalize($1)):
            return _is_$1_updated ')dnl
define(`simple_sync_set', `typename(capitalize($1)):
            _is_$1_updated = state')dnl

object_store(specialty, PREDEFINED)
object_store(equipment, PREDEFINED)
object_store(faculty, PREDEFINED)
object_store(character, PREDEFINED)
object_store(grant, PREDEFINED)
object_store(goal, PREDEFINED)
object_store(event, PREDEFINED)

var grant_to_faculty = {}

func get_sim_state_of(class_):
    match class_.get_name():
        simple_sync_get(character)
        simple_sync_get(faculty)
        simple_sync_get(specialty)
        simple_sync_get(equipment)
        simple_sync_get(grant)
        simple_sync_get(goal)
        _:
            return null


func set_sim_state_of(class_, state=T.SimState.OUT_OF_SYNC):
    match class_.get_name():
        simple_sync_set(character)
        simple_sync_set(faculty)
        simple_sync_set(specialty)
        simple_sync_set(equipment)
        simple_sync_set(grant)
        simple_sync_set(goal)


func build_map(from_list, to_dict, _resource_name):
    for elem in from_list:
        to_dict[elem.uid] = elem


func load_characters():
    randomize()
    var character_data = utils.json_readf(OBJECT_DATA_DIR + "character.json")
    for data in character_data.values():
        var modifiers_data = data.get("modifiers", [])
        var modifiers = []
        for mod_data in modifiers_data:
            modifiers.append(parse_modifier(mod_data))
        var specialty_uid = data["specialty_uid"]
        if specialty_uid == consts.RANDOM:
            specialty_uid = utils.random_choice(SPECIALTY_LIST).uid
        var character = T.Character.new(
            data["name"],
            data.get("icon_uid", null),
            specialty_uid,
            data.get("cost_per_year", 50),
            data.get("price", 300),
            data.get("level", null),
            data.get("description", null),
            data.get("title", null),
            modifiers
        )
        var overrides = data.get("overrides", null)
        if overrides != null:
            character.is_available = overrides.get("is_available", false)
            character.is_hired = overrides.get("is_hired", false)
        load_uid(character, data)
        CHARACTER_LIST.append(character)


func load_uid(obj, data):
    obj.uid = data.get("uid", obj.uid)


func load_specialtys():
    var specialties_data = utils.json_readf(OBJECT_DATA_DIR + "specialties.json")
    for data in specialties_data:
        SPECIALTY_LIST.append(T.Specialty.new(data["name"], data.get("color", null)))


func parse_modifier(data):
    return T.FacultyModifier.new(
        stepify(data["value"], 0.01),
        data["property"],
        data.get("absolute", false),
        data.get("positive", true)
    )


func load_equipments():
    var equipment_data = utils.json_readf(OBJECT_DATA_DIR + "equipment.json")
    for data in equipment_data.values():
        var modifiers_data = data.get("modifiers", [])
        var modifiers = []
        for mod_data in modifiers_data:
            modifiers.append(parse_modifier(mod_data))
        var equipment = T.Equipment.new(
            data["name"],
            data.get("icon_uid", null),
            data["price"],
            modifiers
        )
        load_uid(equipment, data)
        EQUIPMENT_LIST.append(equipment)


func load_grants():
    var grant_data = utils.json_readf(OBJECT_DATA_DIR + "grants.json")
    for data in grant_data.values():
        # TODO: freeze defaults in _init and here
        var grant = T.Grant.new(
            data["name"],
            data.get("amount", 100),
            data.get("years_left", 5),
            data["specialty_uid"],
            data["difficulty"],
            data.get("level", 1),
            data.get("description", null),
            data.get("icon_uid", null),
            data.get("background_uid", null)
        )
        load_uid(grant, data)
        GRANT_LIST.append(grant)


func load_goals():
    var goal_data = utils.json_readf(OBJECT_DATA_DIR + "goals.json")
    for data in goal_data.values():
        var goal = T.Goal.new(
            data["name"],
            data["description"],
            data.get("icon_uid", null),
            data["requirements"]
        )
        load_uid(goal, data)
        GOAL_LIST.append(goal)


func load_facultys():
    var faculties_data = utils.json_readf(OBJECT_DATA_DIR + "faculties.json")
    for data in faculties_data.values():
        # TODO: freeze defaults in _init and here
        var faculty = T.Faculty.new(
            data["name"],
            data["specialty_uid"],
            data.get("icon_uid", null),
            data.get("open_cost", 1000),
            data.get("default_cost", 100),
            data.get("default_enrollee_count", 15),
            data.get("default_enrolee_cost", 5),
            data.get("default_breakthrough_chance", 15),
            data.get("equipment", [])
        )
        load_uid(faculty, data)
        FACULTY_LIST.append(faculty)


func parse_option(data):
    var modifiers_data = data.get("modifiers", [])
    var modifiers = []
    for mod_data in modifiers_data:
        modifiers.append(parse_modifier(mod_data))

    return T.Option.new(data["name"], modifiers)


func load_events():
    var events_data = utils.json_readf(OBJECT_DATA_DIR + "events.json")
    for data in events_data:
        var modifiers_data = data.get("modifiers", [])
        var modifiers = []
        for mod_data in modifiers_data:
            modifiers.append(parse_modifier(mod_data))

        var options_data = data.get("options", [])
        var options = []
        for op_data in options_data:
            options.append(parse_option(op_data))

        var event = T.Event.new(
            data["name"],
            data.get("description", ""),
            data["script"],
            data.get("params", {}),
            data.get("visuals", {}),
            options,
            modifiers
        )
        load_uid(event, data)
        EVENT_LIST.append(event)


define(`_load_resource', `load_`'$1`'s()
    build_map(upcase($1)_LIST, upcase($1)_MAP, "$1")dnl
')dnl
func load_resources():
    # TODO: checks for uniquness of all uids
    _load_resource(specialty)
    _load_resource(equipment)
    _load_resource(grant)
    _load_resource(goal)
    _load_resource(faculty)
    _load_resource(character)
    _load_resource(event)
    for grant in GRANT_LIST:
        grant_to_faculty[grant.uid] = null


func spend_money(amount: int) -> bool:
    if money < amount:
        emitter.call_func("money_error")
        return false
    money -= amount
    emitter.call_func("money_updated", money, false)
    return true


func gain_money(amount: int) -> bool:
    money += amount
    emitter.call_func("money_updated", money, true)
    return true


func format_date(datetime_):
    return tr(MONTH_NAMES[datetime_["month"]]) + ", " + str(datetime_["year"])


func next_date():
    var month = datetime["month"]
    month += 1
    if month > 11:
        month -= 12
        datetime["year"] += 1
    datetime["month"] = month
    emitter.call_func("date_updated", format_date(datetime))
    return datetime


func remove_goal(goal_uid):
    GOAL_LIST.remove(_find_in_goal_list(goal_uid))
    GOAL_MAP.erase(goal_uid)


func change_reputation(amount):
    reputation += amount
    if reputation < 0:
        reputation = 0
    emitter.call_func("reputation_updated", reputation, amount > 0)
