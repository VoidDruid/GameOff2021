enum SimState {IN_SYNC=1, OUT_OF_SYNC=0}
enum UpdateType {FACULTY, GRANT, CHARACTER, GOAL}

class SimObject:
    var uid: String

    func _init():
        uid = utils.get_uid()


class SimNamedObject extends SimObject:
    static func get_name():
        return "class_SimNamedObject"

    var name: String

    func _init(name_):
        name = name_


class Specialty extends SimNamedObject:
    static func get_name():
        return "class_Specialty"

    var color: Color

    func _init(name_, color_hex_=null).(name_):
        uid = name_
        color = Color(color_hex_)


class Faculty extends SimNamedObject:
    static func get_name():
        return "class_Faculty"

    var specialty_uid: String
    var equipment_uid_list = []
    var default_cost = 100
    var default_enrollee_count = 15
    var default_enrollee_cost = 5
    var default_breakthrough_chance = 15
    var icon_uid = null

    ### Dynamic fields ###
    var leader_uid = null
    var breakthrough_chance: int
    var enrollee_count: int
    var enrollee_cost: int
    var yearly_cost: int
    var staff_uid_list = []
    var modifiers = []
    var level: int = 1
    var is_opened: bool = false
    var grant_uid = null
    # Mods
    var character_mods_abs = {}
    var character_mods_rel = {}
    var equipment_mods_abs = {}
    var equipment_mods_rel = {}
    var leader_mods_abs = {}
    var leader_mods_rel = {}

    func get_equipment_effect() -> String:
        return "EQUIPMENT EFFECT"  # TODO: calc effect

    func get_staff_effect() -> String:
        return "STAFF EFFECT"  # TODO: calc effect

    func _init(name_, specialty_uid_, icon_uid_=null, default_cost_=100, default_enrollee_count_=15, default_enrollee_cost_=5, default_breakthrough_chance_=15, equipment_uid_list_=[]).(name_):
        uid = name
        specialty_uid = specialty_uid_
        if icon_uid_ != null:
            icon_uid = "faculty" + "_" + icon_uid_
        default_cost = default_cost_
        default_enrollee_count = default_enrollee_count_
        default_enrollee_cost = default_enrollee_cost_
        default_breakthrough_chance = default_breakthrough_chance_
        equipment_uid_list = equipment_uid_list_


class FacultyModifier:
    var value: float
    var absolute: bool
    var property: String
    var positive: bool = true

    func _init(value_, property_, absolute_=false, positive_=true):
        value = value_
        absolute = absolute_
        property = property_
        positive = positive_

    func apply(faculty: Faculty, scale=1.0):
        var new_value = faculty.get(property)
        if absolute:
            new_value += value * scale
        else:
            new_value *= 1 + (value * scale)
        new_value = int(round(new_value))
        faculty.set(property, new_value)


class SimEntity extends SimNamedObject:
    static func get_name():
        return "class_SimEntity"

    var icon_uid = null
    var modifiers = []

    func get_effect():
        return "Effect! La la la" # TODO: real, translatable effect string

    func _init(name_, icon_uid_, modifiers_=[]).(name_):
        icon_uid = icon_uid_
        modifiers = modifiers_


class Character extends SimEntity:
    static func get_name():
        return "class_Character"

    var short_name: String
    var specialty_uid: String
    var cost_per_year: int
    var price: int
    var level: int

    ### Dynamic fields ###
    var is_available: bool = false
    var is_hired: bool = false
    var faculty_uid = null
    var description = null

    func _init(name_, icon_uid_, specialty_uid_, cost_per_year_=50, price_=300, level_=null, description_=null, modifiers_=[]).(name_, icon_uid_, modifiers_):
        specialty_uid = specialty_uid_
        if icon_uid_ != null:
            icon_uid = "character" + "_" + icon_uid_
        short_name = "SHORT_" + name  # TODO: or generate if no translation found
        cost_per_year = cost_per_year_
        price = price_
        if level_ == null:
            level_ = 2  # TODO: auto calculate level
        level = level_
        if description_ == null:
            description_ = "GENERIC_DESCRIPTION_" + str(level_)
        description = description_


class Equipment extends SimEntity:
    static func get_name():
        return "class_Equipment"

    var price: int
    var available_for = []

    ### Dynamic fields ###
    var is_active: bool = false

    func _init(name_, icon_uid_, price_, modifiers_=[]).(name_, icon_uid_, modifiers_):
        price = price_
        if icon_uid_ != null:
            icon_uid = "equipment" + "_" + icon_uid_

    func to_string():
        return "<Equipment " + name + " " + str(price) + " " + str(modifiers) + " " + str(available_for) + ">"


class Grant extends SimNamedObject:
    static func get_name():
        return "class_Grant"

    var description = null
    var background_uid = null
    var icon_uid = null
    var amount: int = 100
    var specialty_uid = null
    var level = 1
    var difficulty = 1

    ### Dynamic fields ###
    var is_available: bool = false
    var is_taken: bool = false
    var is_in_progress = false
    var is_completed = false
    var chance: int = 0

    func _init(name_, amount_, specialty_uid_, difficulty_, level_, description_=null, icon_uid_=null,  background_uid_=null).(name_):
        uid = name_
        amount = amount_
        specialty_uid = specialty_uid_
        difficulty = difficulty_
        level = level_
        if description_ == null:
            description_ = "DESCRIPTION_" + name_
        description = description_
        if icon_uid_ != null:
            icon_uid = "grant" + "_" + icon_uid_
        background_uid = background_uid_


class Goal extends SimNamedObject:
    static func get_name():
        return "class_Goal"

    var description = null
    var icon_uid = null
    var requirements = null

    ### Dynamic fields ###
    var progress: int = 0

    func _init(name_, description_, icon_uid_, requirements_).(name_):
        uid = name_
        description = description_
        if icon_uid_ != null:
            icon_uid = "goal" + "_" + icon_uid_
        requirements = requirements_


#####################################################################################
######################################## API ########################################
#####################################################################################


class CharactersData:
    var available_characters = []
    var hired_characters = []
    
    func _init(_available_characters = [],_hired_characters = []):
        available_characters = _available_characters
        hired_characters = _hired_characters
        

class GrantsData:
    var current_grants = []
    var available_grants = []
    var completed_grants = []
    var goals = []
    
    func _init(_current_grants = [],_available_grants = [],_completed_grants = [],_goals = []):
        current_grants = _current_grants
        available_grants = _available_grants
        completed_grants = _completed_grants
        goals = _goals
        
