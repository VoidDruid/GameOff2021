var campus_level = 1
var money = 1000
var reputation = 80
var datetime = {
    "month": 1,
    "day": 1,
    "year": 2021,
}

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
    for obj in upcase($1)_LIST:
        if obj.uid == $1.uid:
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
object_store(character, IN-GAME)
object_store(grant, PREDEFINED)
object_store(goal, PREDEFINED)

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


# TODO: actual generation
func generate_starting_characters():
    add_character(T.Character.new("NAME1", "0", SPECIALTY_LIST[0].uid))

    var c = T.Character.new("NAME2", "0", SPECIALTY_LIST[1].uid, 70, 400)
    c.is_available = true
    add_character(c)

    c = T.Character.new("NAME3", "0", SPECIALTY_LIST[0].uid)
    c.is_hired = true
    c.cost_per_year = 20
    add_character(c)


func load_uid(obj, data):
    obj.uid = data.get("uid", obj.uid)


func load_specialties():
    var specialties_data = utils.json_readf(OBJECT_DATA_DIR + "specialties.json")
    for data in specialties_data:
        SPECIALTY_LIST.append(T.Specialty.new(data["name"]))


func parse_modifier(data):
    return T.FacultyModifier.new(data["value"], data["property"], data.get("absolute", false))


func load_equipment():
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


func load_faculties():
    var faculties_data = utils.json_readf(OBJECT_DATA_DIR + "faculties.json")
    for data in faculties_data.values():
        # TODO: freeze defaults in _init and here
        var faculty = T.Faculty.new(
            data["name"],
            data["specialty_uid"],
            data.get("icon_uid", null),
            data.get("default_cost", 100),
            data.get("default_enrollee_count", 15),
            data.get("default_enrolee_cost", 5),
            data.get("default_breakthrough_chance", 15),
            data.get("equipment", [])
        )
        load_uid(faculty, data)
        FACULTY_LIST.append(faculty)


func load_resources():
    load_specialties()
    load_equipment()
    load_grants()
    load_goals()
    load_faculties()
    build_map(SPECIALTY_LIST, SPECIALTY_MAP, "specialty")
    build_map(EQUIPMENT_LIST, EQUIPMENT_MAP, "equipment")
    build_map(GRANT_LIST, GRANT_MAP, "grant")
    build_map(GOAL_LIST, GOAL_MAP, "goal")
    build_map(FACULTY_LIST, FACULTY_MAP, "faculty")
    generate_starting_characters()


func spend_money(amount: int) -> bool:
    if money <= amount:
        emitter.call_func("money_error")
        return false
    money -= amount
    emitter.call_func("money_updated", money, false)
    return true


func gain_money(amount: int) -> bool:
    money += amount
    emitter.call_func("money_updated", money, true)
    return true
