extends Node
class_name SimulationCore

export var RANDOMIZATION_FOR_DEBUG = false
var T = load("res://logic/simulation/Classes.gd")
var StorageT = load("res://logic/simulation/Storage.gd")
var Storage = StorageT.new()


func update_character(character):
    character.is_available = false

    if character.is_hired:
        character.is_available = true

    if Storage.campus_level >= character.level:
        character.is_available = true


func get_characters_list(is_hired=false, for_faculty=null):
    if for_faculty != null and typeof(for_faculty) == TYPE_STRING:
        for_faculty = Storage.get_faculty(for_faculty)
    var update_dynamic = Storage.get_sim_state_of(T.Character)

    var fitting_characters = []

    for character in Storage.CHARACTER_LIST:
        if update_dynamic:
            update_character(character)
        if character.is_hired != is_hired:
            continue
        if for_faculty != null:
            if character.specialty_uid == for_faculty.specialty_uid:
                fitting_characters.append(character)
            else:
                continue
        fitting_characters.append(character)

    if update_dynamic:
        Storage.set_sim_state_of(T.Character, T.SimState.IN_SYNC)

    return fitting_characters


func _ready():
    Storage.load_resources()
    var dt = get_characters_data()
    print_debug(dt.available_characters[0].name)
    pass


#####################################################################################
######################################## API ########################################
#####################################################################################


class CharactersData:
    var available_characters = []
    var hired_characters = []

    func _init(available_characters_=[], hired_characters_=[]):
        available_characters = available_characters_
        hired_characters_ = hired_characters_


func get_characters_data() -> CharactersData:
    return CharactersData.new(
        get_characters_list(false),
        get_characters_list(true)
    )
