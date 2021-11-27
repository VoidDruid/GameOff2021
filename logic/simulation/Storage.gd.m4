var campus_level = 1
var money = 1000
var reputation = 80
var datetime = {
    "month": 1,
    "day": 1,
    "year": 2021,
}

var T = load("res://logic/simulation/Classes.gd")
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

func get_sim_state_of(class_):
    match class_.get_name():
        simple_sync_get(character)
        simple_sync_get(faculty)
        simple_sync_get(specialty)
        simple_sync_get(equipment)
        _:
            return null


func set_sim_state_of(class_, state=T.SimState.OUT_OF_SYNC):
    match class_.get_name():
        simple_sync_set(character)
        simple_sync_set(faculty)
        simple_sync_set(specialty)
        simple_sync_set(equipment)


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


func spend_money(amount: int) -> bool:
    if money <= amount:
        return false
    money -= amount
    return true
