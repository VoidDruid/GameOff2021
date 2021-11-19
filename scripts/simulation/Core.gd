extends Node

class_name SimulationCore


class SimObject:
    var uid: String

    func _init():
        uid = utils.get_uid()


class SimNamedObject extends SimObject:
    var name: String

    func _init(name_):
        name = name_


class Specialty extends SimNamedObject:
    func _init(name_).(name_):
        uid = name_


class Faculty extends SimNamedObject:
    var built: bool = false
    var specialty_uid: String
    var leader_uid: String
    var breakthrough_chance: int
    var enrollee_count: int
    var yearly_cost: int
    var researcher_uid_list = []
    var equipment_uid_list = []

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
    var icon_uid: String
    var modifiers = []

    func _init(name_, icon_uid_, modifiers_=[]).(name_):
        icon_uid = icon_uid_
        modifiers = modifiers_


class Character extends SimEntity:
    var short_name: String
    var specialty_uid: int

    func _init(name_, icon_uid_, specialty_uid_, modifiers_=[]).(name_, icon_uid_, modifiers_):
        specialty_uid = specialty_uid_
        icon_uid = "character_" + icon_uid
        short_name = "SHORT_" + name


class Equipment extends SimEntity:
    var price: int
    var available_for = []

    func _init(name_, icon_uid_, price_, modifiers_=[], available_for_=[]).(name_, icon_uid_, modifiers_):
        price = price_
        icon_uid = "equipment_" + icon_uid
        available_for = available_for_


# NOTE: PREDEFINED
var SPECIALTY_LIST = [Specialty.new("PHYSICS_")]
var SPECIALTY_MAP = {}

# NOTE: PREDEFINED
var EQUIPMENT_LIST = [Equipment.new("PRINTER", 0, 1000, [])]
var EQUIPMENT_MAP = {}

# NOTE: GENERATED IN-GAME
var CHARACTER_LIST = []
var CHARACTER_MAP = {}


func build_map(from_list, to_dict, _resource_name):
    # TODO: load data for list from json at _resource_name
    for elem in from_list:
        to_dict[elem.uid] = elem


func add_character(character):
    CHARACTER_LIST.append(character)
    CHARACTER_MAP[character.uid] = character


func generate_starting_characters():
    add_character(Character.new("NAME1", 0, SPECIALTY_LIST[0].uid, []))


func _init():
    build_map(SPECIALTY_LIST, SPECIALTY_MAP, "specialty")
    build_map(EQUIPMENT_LIST, EQUIPMENT_MAP, "equipment")
    generate_starting_characters()


class FrontendState:
    var money: int
    var trust: int

    func _init():
        pass


func get_frontend_state() -> FrontendState:
    return FrontendState.new()
