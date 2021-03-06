var Storage = null
var T = null
var emitter = null
var logger = null


func update_character(character):
    if character.is_hired:
        character.is_available = true

    if Storage.campus_level >= character.level:
        character.is_available = true


func update_grant(grant):
    grant.is_available = Storage.campus_level >= grant.level

    if grant.is_completed:
        grant.is_taken = true
        grant.is_in_progress = false

    if grant.is_in_progress:
        grant.is_taken = true

    if grant.is_taken or grant.is_in_progress:
        grant.is_available = true


func process_object_modifiers(object, faculty, abs_container, rel_container, scale=1.0):
    for modifier in object.modifiers:
        var mods_d = abs_container if modifier.absolute else rel_container
        if "specialty_uid" in object:
            scale = (1.0 if object.specialty_uid == faculty.specialty_uid else 0.5) * scale
        else:
            scale = 1.0
        var mod = modifier.value * scale
        if modifier.property in mods_d:
            if modifier.absolute:
                mods_d[modifier.property] += mod
            else:
                mods_d[modifier.property] *= 1 + mod
        else:
            mods_d[modifier.property] = mod if modifier.absolute else (1 + mod)
        modifier.apply(faculty, scale)


func update_faculty(faculty):
    if  not faculty.is_opened:
        return

    faculty.monthly_event_chance = faculty.default_monthly_event_chance
    faculty.enrollee_cost = faculty.default_enrollee_cost
    faculty.breakthrough_chance = faculty.default_breakthrough_chance

    var grant = null
    if faculty.grant_uid != null:
        grant = Storage.get_grant(faculty.grant_uid)
        if grant.specialty_uid != faculty.specialty_uid:
            faculty.breakthrough_chance *= 0.5
        faculty.breakthrough_chance *= (1 - grant.difficulty / 200)

    var character_mods_abs = {}
    var character_mods_rel = {}
    var to_remove = []
    var i = 0
    var characters_count = 0
    var average_characters_level = 1
    for character_uid in faculty.staff_uid_list:
        var character = Storage.get_character(character_uid)
        if not character.is_hired:
            to_remove.append(i)
        else:
            characters_count += 1
            average_characters_level += character.level
            process_object_modifiers(character, faculty, character_mods_abs, character_mods_rel)
        i += 1
    if characters_count == 0:
        average_characters_level = 1
    else:
        average_characters_level /= characters_count
    faculty.character_mods_abs = character_mods_abs
    faculty.character_mods_rel = character_mods_rel

    for i_remove in to_remove:
        faculty.staff_uid_list.remove(i_remove)

    faculty.yearly_cost = faculty.default_cost + faculty.enrollee_count * faculty.default_enrollee_cost

    var active_equipment_count = 0
    var equipment_mods_abs = {}
    var equipment_mods_rel = {}
    for equipment_uid in faculty.equipment_uid_list:
        var equipment = Storage.get_equipment(equipment_uid)
        if not equipment.is_active:
            continue
        active_equipment_count += 1
        process_object_modifiers(equipment, faculty, equipment_mods_abs, equipment_mods_rel)
    faculty.equipment_mods_abs = equipment_mods_abs
    faculty.equipment_mods_rel = equipment_mods_rel

    var leader_mods_abs = {}
    var leader_mods_rel = {}
    var leader_level = 1
    if faculty.leader_uid != null:
        var leader = Storage.get_character(faculty.leader_uid)
        if not leader.is_hired:
            faculty.leader_uid = null
        else:
            leader_level = leader.level
            process_object_modifiers(leader, faculty, leader_mods_abs, leader_mods_rel, 2.0)
    faculty.leader_mods_abs = leader_mods_abs
    faculty.leader_mods_rel = leader_mods_rel

    faculty.level = clamp(floor(
        clamp(leader_level, 1, 3) +
        clamp(int(active_equipment_count / 2), 1, 3) +
        clamp(average_characters_level, 1, 3)
    ) / 2.5, 1, 3)
    # TODO: updating campus should be a separate function
    var avg_level = 0
    var fac_count = 0
    for faculty in Storage.FACULTY_LIST:
        if not faculty.is_opened:
            continue
        avg_level += faculty.level
        fac_count += 1
    avg_level = int(round(avg_level / fac_count))
    if avg_level < Storage.campus_level:
        Storage.campus_level = avg_level
        emitter.call_func("campus_level_updated", Storage.campus_level)
        Storage.set_sim_state_of(T.Grant, T.SimState.OUT_OF_SYNC)
        Storage.set_sim_state_of(T.Character, T.SimState.OUT_OF_SYNC)
        update_grants()
        update_characters()

    if grant != null:
        grant.chance = faculty.breakthrough_chance


func update_faculties():
    var is_synced = Storage.get_sim_state_of(T.Faculty)
    if is_synced:
        return
    for faculty in Storage.FACULTY_LIST:
        update_faculty(faculty)
    Storage.set_sim_state_of(T.Faculty, T.SimState.IN_SYNC)


func update_characters():
    var is_synced = Storage.get_sim_state_of(T.Character)
    if is_synced:
        return
    for character in Storage.CHARACTER_LIST:
        update_character(character)
    Storage.set_sim_state_of(T.Character, T.SimState.IN_SYNC)


func update_grants():
    var is_synced = Storage.get_sim_state_of(T.Grant)
    if is_synced:
        return
    for grant in Storage.GRANT_LIST:
        update_grant(grant)
    Storage.set_sim_state_of(T.Grant, T.SimState.IN_SYNC)


func update_goal(goal):
    var done_m = {}
    var total_req = len(goal.requirements.get('_GRANTS_', []))
    var done_req = 0
    for specialty_uid in goal.requirements:
        if specialty_uid == "_GRANTS_":
            continue
        done_m[specialty_uid] = 0
        total_req += goal.requirements[specialty_uid]
    for grant in Storage.GRANT_LIST:
        if not grant.is_completed:
            continue
        if grant.is_failed and grant.uid in goal.requirements["_GRANTS_"]:
            Storage.remove_goal(goal.uid)
            return
        if (not grant.is_failed and
            grant.specialty_uid in goal.requirements and
            done_m[grant.specialty_uid] < goal.requirements[grant.specialty_uid]):
            done_m[grant.specialty_uid] += 1
            done_req += 1

    goal.progress = (done_req / total_req * 100)
    if goal.progress >= 100:
        emitter.call_func("victory", goal.uid)


func update_goals():
    var is_synced = Storage.get_sim_state_of(T.Goal)
    if is_synced:
        return
    for goal in Storage.GOAL_LIST:
        update_goal(goal)
    Storage.set_sim_state_of(T.Goal, T.SimState.IN_SYNC)


func update_all():
    update_characters()
    update_faculties()
    update_grants()
    update_goals()


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
