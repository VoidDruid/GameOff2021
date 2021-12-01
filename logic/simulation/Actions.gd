var Engine = null
var Storage = null
var T = null
var emitter = null


func unassign_grant(faculty, update=true, allowed_updates=null):
    if faculty.grant_uid == null:
        return
    var prev_grant = Storage.get_grant(faculty.grant_uid)
    Storage.grant_to_faculty[faculty.grant_uid] = null
    prev_grant.is_in_progress = false
    prev_grant.chance = 0
    faculty.grant_uid = null

    if update:
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            Engine.update_grant(prev_grant)
            emitter.call_func("grant_updated", prev_grant.uid)


func free_grant(grant, update=true, allowed_updates=null):
    var prev_faculty_uid = Storage.grant_to_faculty[grant.uid]
    if prev_faculty_uid == null:
        return
    var prev_faculty = Storage.get_faculty(prev_faculty_uid)
    prev_faculty.grant_uid = null
    grant.chance = 0

    if update:
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            Engine.update_grant(grant)
            emitter.call_func("grant_updated", grant.uid)
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(prev_faculty)
            emitter.call_func("faculty_updated", prev_faculty.uid)


func remove_character_from_work(character, update=true, allowed_updates=null):
    if character.faculty_uid == null:
        return

    var prev_faculty = Storage.get_faculty(character.faculty_uid)
    if prev_faculty.leader_uid == character.uid:
        prev_faculty.leader_uid = null
    else:
        var prev_index = prev_faculty.staff_uid_list.find(character.uid)
        if prev_index != -1:
            prev_faculty.staff_uid_list.remove(prev_index)

    character.faculty_uid = null

    if update:
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(prev_faculty)
            emitter.call_func("faculty_updated", prev_faculty.uid)
        if allowed_updates == null or T.UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emitter.call_func("character_updated", character.uid)

func assign_leader(faculty_uid,character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    character.is_hired = true
    remove_character_from_work(character, false)

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.leader_uid = character_uid

    if update:
        if allowed_updates == null or T.UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emitter.call_func("character_updated", character.uid)
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)


func assign_grant(faculty_uid,grant_uid, update=true, allowed_updates=null):
    var grant = Storage.get_grant(grant_uid)
    free_grant(grant, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))
    grant.is_in_progress = true

    var faculty = Storage.get_faculty(faculty_uid)
    unassign_grant(faculty, update, [T.UpdateType.GRANT] if allowed_updates == null else utils.intersection([T.UpdateType.GRANT], allowed_updates))
    faculty.grant_uid = grant_uid
    Storage.grant_to_faculty[grant_uid] = faculty_uid

    if update:
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            Engine.update_grant(grant)
            emitter.call_func("grant_updated", grant.uid)
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)


func add_staff(faculty_uid,character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    character.is_hired = true
    remove_character_from_work(character, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.staff_uid_list.append(character_uid)

    if update:
        if allowed_updates == null or T.UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emitter.call_func("character_updated", character.uid)
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)


func remove_staff(faculty_uid,character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    if character.faculty_uid != faculty_uid:
        utils.notify_error({
            "character_uid": character_uid,
            "faculty_uid": faculty_uid,
            "error": "Tried to remove staff from faculty, but character not working here!"
        })
        return
    remove_character_from_work(character, update, allowed_updates)


func buy_equipment(faculty_uid,equipment_uid, update=true, allowed_updates=null):
    var equipment = Storage.get_equipment(equipment_uid)
    if equipment.is_active:
        utils.notify_error({
            "equipment_uid": equipment_uid,
            "faculty_uid": faculty_uid,
            "error": "Tried to buy equipment, but it is already active!"
        })
        return
    if not Storage.spend_money(equipment.price):
        return
    equipment.is_active = true

    if update:
        var faculty = Storage.get_faculty(faculty_uid)
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)


func set_enrollee_count(faculty_uid,count, update=true, allowed_updates=null):
    var faculty = Storage.get_faculty(faculty_uid)
    faculty.enrollee_count = count

    if update:
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)


func hire_character(character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    if character.is_hired or not character.is_available:
        utils.notify_error({
            "character_uid": character_uid,
            "error": "Tried to hire character, that is either not available or already hired!"
        })
        return
    if not Storage.spend_money(character.price):
        return
    character.is_hired = true

    if update:
        if allowed_updates == null or T.UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emitter.call_func("character_updated", character.uid)

func fire_character(character_uid, update=true, allowed_updates=null):
    var character = Storage.get_character(character_uid)
    if not character.is_hired:
        utils.notify_error({
            "character_uid": character_uid,
            "error": "Tried to fire character, that is not hired!"
        })
        return
    remove_character_from_work(character, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))
    character.is_hired = false

    if update:
        if allowed_updates == null or T.UpdateType.CHARACTER in allowed_updates:
            Engine.update_character(character)
            emitter.call_func("character_updated", character.uid)


func take_grant(grant_uid, update=true, allowed_updates=null):
    var grant = Storage.get_grant(grant_uid)
    if not grant.is_available or grant.is_taken:
        utils.notify_error({
            "grant_uid": grant_uid,
            "error": "Tried to take grant, that is either not available or already taken!"
        })
        return
    Storage.gain_money(grant.amount)
    grant.is_taken = true

    if update:
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            Engine.update_grant(grant)
            emitter.call_func("grant_updated", grant.uid)


func open_faculty(faculty_uid, update=true, allowed_updates=null):
    var faculty = Storage.get_faculty(faculty_uid)
    if not Storage.spend_money(faculty.open_cost):
        return
    faculty.is_opened = true

    if update:
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)
            emitter.call_func("faculties_updated")


func step_month():
    Storage.next_date()


func decrement_years_on_grants(update=true, allowed_updates=null):
    var updated_faculties = []

    for grant in Storage.GRANT_LIST:
        if not grant.is_taken or grant.is_completed:
            continue
        grant.years_left -= 1

        if Storage.grant_to_faculty[grant.uid] != null:
                updated_faculties.append(Storage.grant_to_faculty[grant.uid])

        if grant.years_left <= 0:
            grant.is_completed = true
            grant.is_failed = true
            emitter.call_func("update_log", [tr("GRANT_FAILED") + " - " + tr(grant.name)])
            free_grant(grant, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))
            continue

        if Storage.grant_to_faculty[grant.uid] == null:
            continue

        var roll = randi() % 100
        print_debug(roll, " ", grant.chance)
        if roll >= grant.chance:
            grant.is_completed = true
            emitter.call_func("update_log", [tr("GRANT_COMPLETED") + " - " + tr(grant.name)])
            free_grant(grant, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))

    Storage.set_sim_state_of(T.Goal, T.SimState.OUT_OF_SYNC)
    Engine.update_goals()
    if 17 == 0:
        emitter.call_func("game_over")

    if update:
        if allowed_updates == null or T.UpdateType.GOAL in allowed_updates:
            emitter.call_func("goals_updated")
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            emitter.call_func("grants_updated")
        for faculty_uid in updated_faculties:
            if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
                emitter.call_func("faculty_updated", faculty_uid)
