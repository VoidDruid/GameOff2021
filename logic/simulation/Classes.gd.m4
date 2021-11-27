define(`NCLASS', `class $1 extends $2:
    static func get_name():
        return typename($1)
')dnl
define(`DATACLASS', `class $1:
    foreach(`vb', (`shift($*)'), `var vb
    ')dnl

    func _init(shift(foreach(`vb', (`shift($*)'), `,concat(_, vb)'))):
        foreach(`vb', (`shift($*)'), `dnl
substr(vb, 0, decr(index(vb, `='))) = concat(_, substr(vb, 0, decr(index(vb, `='))))
        ')dnl
')dnl
enum SimState {IN_SYNC=1, OUT_OF_SYNC=0}


class SimObject:
    var uid: String

    func _init():
        uid = utils.get_uid()


NCLASS(SimNamedObject, SimObject)
    var name: String

    func _init(name_):
        name = name_


NCLASS(Specialty, SimNamedObject)
    func _init(name_).(name_):
        uid = name_


NCLASS(Faculty, SimNamedObject)
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


NCLASS(SimEntity, SimNamedObject)
    var icon_uid: String
    var modifiers = []

    func get_effect():
        return "Effect! La la la" # TODO: real, translatable effect string

    func _init(name_, icon_uid_, modifiers_=[]).(name_):
        icon_uid = icon_uid_
        modifiers = modifiers_


NCLASS(Character, SimEntity)
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


NCLASS(Equipment, SimEntity)
    var price: int
    var available_for = []

    func _init(name_, icon_uid_, price_, modifiers_=[], available_for_=[]).(name_, icon_uid_, modifiers_):
        price = price_
        icon_uid = "equipment_" + icon_uid
        available_for = available_for_

    func to_string():
        return "<Equipment " + name + " " + str(price) + " " + str(modifiers) + " " + str(available_for) + ">"


NCLASS(Grant, SimNamedObject)
    var description = null
    var background_uid = null
    var icon_uid = null
    var amount: int = 100
    var specialty_uid = null

    ### Dynamic fields ###
    var is_available: bool = false
    var chance: int = 0

    func _init(name_, amount_, specialty_uid_, description_, icon_uid_,  background_uid_).(name_):
        uid = name_
        amount = amount_
        specialty_uid = specialty_uid_
        description = description_
        icon_uid = icon_uid_
        background_uid = background_uid_


#####################################################################################
######################################## API ########################################
#####################################################################################


DATACLASS(CharactersData, available_characters = [], hired_characters = [])

DATACLASS(GrantsData, current_grants = [], available_grants = [], completed_grants = [], goals = [])
