var Storage = null
var emitter = null


func update_character(character):
    if character.is_hired:
        character.is_available = true

    if Storage.campus_level >= character.level:
        character.is_available = true
