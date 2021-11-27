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

    func _init(name_).(name_):
        uid = name_


class Faculty extends SimNamedObject:
    static func get_name():
        return "class_Faculty"

    var specialty_uid: String

    ### Dynamic fields ###
    var leader_uid: String
    var breakthrough_chance: int
    var enrollee_count: int
    var yearly_cost: int
    var researcher_uid_list = []
    var equipment_uid_list = []
    var level: int = 1
    var is_opened: bool = false

    func _init(name_).(name_):
        pass


class FacultyModifier:
    var value: float
    var absolute: bool
    var property: String

    func _init(value_, property_, absolute_=false):
        value = value_
        absolute = absolute_
        property = property_

    func apply(faculty: Faculty):
        var new_value = faculty.get(property)
        if absolute:
            new_value += value
        else:
            new_value *= value
        new_value = int(round(new_value))
        faculty.set(property, new_value)


class SimEntity extends SimNamedObject:
    static func get_name():
        return "class_SimEntity"

    var icon_uid: String
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

    func _init(name_, icon_uid_, specialty_uid_, cost_per_year_=50, price_=300, level_=null, modifiers_=[]).(name_, icon_uid_, modifiers_):
        specialty_uid = specialty_uid_
        icon_uid = "character_" + icon_uid
        short_name = "SHORT_" + name  # TODO: or generate if no translation found
        cost_per_year = cost_per_year_
        price = price_
        if level_ == "auto" or level_ == null:
            level_ = 2  # TODO: auto calculate level
        level = level_


class Equipment extends SimEntity:
    static func get_name():
        return "class_Equipment"

    var price: int
    var available_for = []

    func _init(name_, icon_uid_, price_, modifiers_=[], available_for_=[]).(name_, icon_uid_, modifiers_):
        price = price_
        icon_uid = "equipment_" + icon_uid
        available_for = available_for_

    func to_string():
        return "<Equipment " + name + " " + str(price) + " " + str(modifiers) + " " + str(available_for) + ">"


enum SimState {IN_SYNC=1, OUT_OF_SYNC=0}


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
        