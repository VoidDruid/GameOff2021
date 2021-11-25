var campus_level = 1

var T = load("res://logic/simulation/Classes.gd")

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


func build_map(from_list, to_dict, _resource_name):
    for elem in from_list:
        to_dict[elem.uid] = elem


func generate_starting_characters():
    add_character(T.Character.new("NAME1", "0", SPECIALTY_LIST[0].uid))


func load_specialties():
    var specialties_data = utils.json_readf("res://gamedata/specialties.json")
    for data in specialties_data:
        SPECIALTY_LIST.append(T.Specialty.new(data["name"]))


func parse_modifier(data):
    return T.FacultyModifier.new(data["value"], data["property"], data.get("absolute", false))


func load_equipment():
    var equipment_data = utils.json_readf("res://gamedata/equipment.json")
    for data in equipment_data:
        var modifiers_data = data.get("modifiers", [])
        var modifiers = []
        for mod_data in modifiers_data:
            modifiers.append(parse_modifier(mod_data))
        EQUIPMENT_LIST.append(T.Equipment.new(
            data["name"],
            data["icon_id"],
            data["price"],
            modifiers,
            data.get("available_for", [])
        ))


func load_resources():
    load_specialties()
    load_equipment()
    build_map(SPECIALTY_LIST, SPECIALTY_MAP, "specialty")
    build_map(EQUIPMENT_LIST, EQUIPMENT_MAP, "equipment")
    generate_starting_characters()
