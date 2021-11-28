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

#NOTE: PREDEFINED
var SPECIALTY_LIST = []
var SPECIALTY_MAP = {}
var _is_specialty_updated = T.SimState.OUT_OF_SYNC


func get_specialty(specialty_uid):
    return SPECIALTY_MAP[specialty_uid]


func _find_in_specialty_list(specialty):
    var i = 0
    for obj in SPECIALTY_LIST:
        if obj.uid == specialty.uid:
            return i
        i += 1
    return null


func add_specialty(specialty, skip_check=false):
    if not skip_check:
        var index = _find_in_specialty_list(specialty)
        if index != null:
            SPECIALTY_LIST.remove(index)
    SPECIALTY_LIST.append(specialty)
    SPECIALTY_MAP[specialty.uid] = specialty

#NOTE: PREDEFINED
var EQUIPMENT_LIST = []
var EQUIPMENT_MAP = {}
var _is_equipment_updated = T.SimState.OUT_OF_SYNC


func get_equipment(equipment_uid):
    return EQUIPMENT_MAP[equipment_uid]


func _find_in_equipment_list(equipment):
    var i = 0
    for obj in EQUIPMENT_LIST:
        if obj.uid == equipment.uid:
            return i
        i += 1
    return null


func add_equipment(equipment, skip_check=false):
    if not skip_check:
        var index = _find_in_equipment_list(equipment)
        if index != null:
            EQUIPMENT_LIST.remove(index)
    EQUIPMENT_LIST.append(equipment)
    EQUIPMENT_MAP[equipment.uid] = equipment

#NOTE: PREDEFINED
var FACULTY_LIST = []
var FACULTY_MAP = {}
var _is_faculty_updated = T.SimState.OUT_OF_SYNC


func get_faculty(faculty_uid):
    return FACULTY_MAP[faculty_uid]


func _find_in_faculty_list(faculty):
    var i = 0
    for obj in FACULTY_LIST:
        if obj.uid == faculty.uid:
            return i
        i += 1
    return null


func add_faculty(faculty, skip_check=false):
    if not skip_check:
        var index = _find_in_faculty_list(faculty)
        if index != null:
            FACULTY_LIST.remove(index)
    FACULTY_LIST.append(faculty)
    FACULTY_MAP[faculty.uid] = faculty

#NOTE: IN-GAME
var CHARACTER_LIST = []
var CHARACTER_MAP = {}
var _is_character_updated = T.SimState.OUT_OF_SYNC


func get_character(character_uid):
    return CHARACTER_MAP[character_uid]


func _find_in_character_list(character):
    var i = 0
    for obj in CHARACTER_LIST:
        if obj.uid == character.uid:
            return i
        i += 1
    return null


func add_character(character, skip_check=false):
    if not skip_check:
        var index = _find_in_character_list(character)
        if index != null:
            CHARACTER_LIST.remove(index)
    CHARACTER_LIST.append(character)
    CHARACTER_MAP[character.uid] = character

#NOTE: PREDEFINED
var GRANT_LIST = []
var GRANT_MAP = {}
var _is_grant_updated = T.SimState.OUT_OF_SYNC


func get_grant(grant_uid):
    return GRANT_MAP[grant_uid]


func _find_in_grant_list(grant):
    var i = 0
    for obj in GRANT_LIST:
        if obj.uid == grant.uid:
            return i
        i += 1
    return null


func add_grant(grant, skip_check=false):
    if not skip_check:
        var index = _find_in_grant_list(grant)
        if index != null:
            GRANT_LIST.remove(index)
    GRANT_LIST.append(grant)
    GRANT_MAP[grant.uid] = grant

#NOTE: PREDEFINED
var GOAL_LIST = []
var GOAL_MAP = {}
var _is_goal_updated = T.SimState.OUT_OF_SYNC


func get_goal(goal_uid):
    return GOAL_MAP[goal_uid]


func _find_in_goal_list(goal):
    var i = 0
    for obj in GOAL_LIST:
        if obj.uid == goal.uid:
            return i
        i += 1
    return null


func add_goal(goal, skip_check=false):
    if not skip_check:
        var index = _find_in_goal_list(goal)
        if index != null:
            GOAL_LIST.remove(index)
    GOAL_LIST.append(goal)
    GOAL_MAP[goal.uid] = goal


func get_sim_state_of(class_):
    match class_.get_name():
        "class_Character":
            return _is_character_updated 
        "class_Faculty":
            return _is_faculty_updated 
        "class_Specialty":
            return _is_specialty_updated 
        "class_Equipment":
            return _is_equipment_updated 
        "class_Grant":
            return _is_grant_updated 
        "class_Goal":
            return _is_goal_updated 
        _:
            return null


func set_sim_state_of(class_, state=T.SimState.OUT_OF_SYNC):
    match class_.get_name():
        "class_Character":
            _is_character_updated = state
        "class_Faculty":
            _is_faculty_updated = state
        "class_Specialty":
            _is_specialty_updated = state
        "class_Equipment":
            _is_equipment_updated = state
        "class_Grant":
            _is_grant_updated = state
        "class_Goal":
            _is_goal_updated = state


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
            data.get("equipment_uid_list", [])
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
