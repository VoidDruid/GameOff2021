var Storage = null
var T = null
var emitter = null


func update_character(character):
    if character.is_hired:
        character.is_available = true

    if Storage.campus_level >= character.level:
        character.is_available = true


func update_grant(grant):
    if grant.is_completed:
        grant.is_taken = true
        grant.is_in_progress = false

    if grant.is_in_progress:
        grant.is_taken = true

    if grant.is_taken or grant.is_in_progress:
        grant.is_available = true

    if Storage.campus_level >= grant.level:
        grant.is_available = true


func update_faculty(faculty):
    # TODO: check characters (fired, specialty, etc.) and apply effects and cost
    # TODO: check leader (fired, specialty, etc.) and apply effects and cost
    # TODO: check enrollees and apply effect and cost
    # TODO: check equipment and apply effects
    # TODO: calculate faculty level
    faculty.breakthrough_chance = faculty.default_breakthrough_chance
    faculty.enrollee_count = faculty.default_enrollee_count
    faculty.enrollee_cost = faculty.default_enrollee_cost
    faculty.yearly_cost = faculty.default_cost


func update_faculties():
    var is_synced = Storage.get_sim_state_of(T.Faculty)
    if is_synced:
        return
    for faculty in Storage.FACULTY_LIST:
        update_faculty(faculty)
    Storage.set_sim_state_of(T.Faculty, T.SimState.IN_SYNC)


func update_goal(_goal):
    # TODO: check how many specific grants completed
    # TODO: check how many grants in each required field completed
    # TODO: calc progress
    pass


func update_goals():
    var is_synced = Storage.get_sim_state_of(T.Goal)
    if is_synced:
        return
    for goal in Storage.GOAL_LIST:
        update_goal(goal)
    Storage.set_sim_state_of(T.Goal, T.SimState.IN_SYNC)


func get_characters_list(is_hired=false, for_faculty=null):
    if for_faculty != null and typeof(for_faculty) == TYPE_STRING:
        for_faculty = Storage.get_faculty(for_faculty)
    var is_synced = Storage.get_sim_state_of(T.Character)

    var fitting_characters = []

    for character in Storage.CHARACTER_LIST:
        if not is_synced:
            update_character(character)
        if character.is_hired != is_hired:
            continue
        if for_faculty != null:
            if character.specialty_uid == for_faculty.specialty_uid:
                fitting_characters.append(character)
            else:
                continue
        fitting_characters.append(character)

    if not is_synced:
        Storage.set_sim_state_of(T.Character, T.SimState.IN_SYNC)

    return fitting_characters


func get_grants_list(filters):
    var for_faculty = filters.get("for_faculty", null)
    if for_faculty != null and typeof(for_faculty) == TYPE_STRING:
        for_faculty = Storage.get_faculty(for_faculty)
    var is_synced = Storage.get_sim_state_of(T.Grant)

    var fitting_grants = []

    for grant in Storage.GRANT_LIST:
        if not is_synced:
            update_grant(grant)

        if for_faculty != null and grant.specialty_uid != for_faculty.specialty_uid:
            continue

        var is_available = filters.get("is_available", null)
        if is_available != null and grant.is_available != is_available:
            continue

        var is_taken = filters.get("is_taken", null)
        if is_taken != null and grant.is_taken != is_taken:
            continue

        var is_in_progress = filters.get("is_in_progress", null)
        if is_in_progress != null and grant.is_in_progress != is_in_progress:
            continue

        var is_completed = filters.get("is_completed", null)
        if is_completed != null and grant.is_completed != is_completed:
            continue

        fitting_grants.append(grant)

    if not is_synced:
        update_goals()
        Storage.set_sim_state_of(T.Grant, T.SimState.IN_SYNC)

    return fitting_grants


func get_goals_list():
    update_goals()
    return Storage.GOAL_LIST


func get_faculty_info(faculty_uid):
    var faculty = Storage.get_faculty(faculty_uid)
    var is_synced = Storage.get_sim_state_of(T.Faculty)
    if not is_synced:
        update_faculty(faculty)
    return faculty
