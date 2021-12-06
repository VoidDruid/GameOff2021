var failure_notice_ref: FuncRef
var success_notice_ref: FuncRef
var important_notice_ref: FuncRef
var emitter = null
var logger = null

var Engine = null
var Storage = null
var T = null


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

    logger.call_func(tr("NEW_LEADER_LOG"), 0.4)

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

    logger.call_func(tr("ASSIGNED_GRANT_LOG"), 0.5)

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

    logger.call_func(tr("ADDED_STAFF_LOG"), 0.3)

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

    logger.call_func(tr("BOUGHT_EQUIPMENT_LOG"), 0.6)

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

    logger.call_func(tr("HIRED_CHARACTER_LOG"), 0.3)

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

    logger.call_func(tr("OPENED_FACULTY_LOG"), 0.7)

    if update:
        if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
            Engine.update_faculty(faculty)
            emitter.call_func("faculty_updated", faculty.uid)
            emitter.call_func("faculties_updated")


func step_month():
    var rolled_event = false
    for faculty in Storage.FACULTY_LIST:
        if (not faculty.is_opened or
            faculty.monthly_event_chance == null or
            faculty.monthly_event_chance <= 0):
            continue
        var roll = utils.with_chance(faculty.monthly_event_chance / 100.0)
        print_debug("F", faculty.monthly_event_chance / 100.0, roll)
        if roll:
            rolled_event = true
    if rolled_event:
        Storage.is_event_active = true
        emitter.call_func("event", utils.random_choice(Storage.EVENT_LIST))

    Storage.next_date()
    return rolled_event


func decrement_years_on_grants(update=true, allowed_updates=null):
    var has_failure = false
    var has_success = false
    var compl_grants = 0
    var updated_faculties = []

    for grant in Storage.GRANT_LIST:
        if grant.is_completed and not grant.is_failed:
            compl_grants += 1
        if not grant.is_taken or grant.is_completed:
            continue

        grant.years_left -= 1

        if Storage.grant_to_faculty[grant.uid] != null:
                updated_faculties.append(Storage.grant_to_faculty[grant.uid])

        if grant.years_left <= 0:
            grant.is_completed = true
            grant.is_failed = true
            has_failure = true
            Storage.change_reputation(-grant.difficulty*0.7)
            emitter.call_func("update_log", [tr("GRANT_FAILED") + " - " + tr(grant.name)])
            free_grant(grant, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))
            continue

        if Storage.grant_to_faculty[grant.uid] == null:
            continue

        var roll = randi() % 100
        if roll <= grant.chance:
            compl_grants += 1
            has_success = true
            grant.is_completed = true
            Storage.change_reputation(int(grant.difficulty*0.4))
            emitter.call_func("update_log", [tr("GRANT_COMPLETED") + " - " + tr(grant.name)])
            free_grant(grant, update, [T.UpdateType.FACULTY] if allowed_updates == null else utils.intersection([T.UpdateType.FACULTY], allowed_updates))

    if compl_grants >= 5:
        Storage.campus_level = 3
        emitter.call_func("campus_level_updated", Storage.campus_level)
        Storage.set_sim_state_of(T.Character, T.SimState.OUT_OF_SYNC)
        Storage.set_sim_state_of(T.Grant, T.SimState.OUT_OF_SYNC)
        Engine.update_characters()
        Engine.update_grants()

    Storage.set_sim_state_of(T.Goal, T.SimState.OUT_OF_SYNC)
    Engine.update_goals()
    if len(Storage.GOAL_LIST) == 0:
        emitter.call_func("game_over")

    if update:
        if allowed_updates == null or T.UpdateType.GOAL in allowed_updates:
            emitter.call_func("goals_updated")
        if allowed_updates == null or T.UpdateType.GRANT in allowed_updates:
            emitter.call_func("grants_updated")
        for faculty_uid in updated_faculties:
            if allowed_updates == null or T.UpdateType.FACULTY in allowed_updates:
                emitter.call_func("faculty_updated", faculty_uid)

        if has_success:
            success_notice_ref.call_func()
            logger.call_func(tr("SUCCESS_LOG"), 0.3)
        else:
            if has_failure:
                failure_notice_ref.call_func()
                logger.call_func(tr("FAILURE_LOG"), 0.3)
            else:
                logger.call_func(tr("QUIER_YEAR_LOG"), 0.2)


func substract_characters_cost(update=true, allowed_updates=null):
    for character in Storage.CHARACTER_LIST:
        if not character.is_hired:
            continue
        Storage.money -= character.cost_per_year

    if allowed_updates == null or T.UpdateType.MONEY in allowed_updates:
        emitter.call_func("money_updated", Storage.money, false)


func substract_faculties_cost(update=true, allowed_updates=null):
    for faculty in Storage.FACULTY_LIST:
        if not faculty.is_opened:
            continue
        Storage.money -= faculty.yearly_cost

    if allowed_updates == null or T.UpdateType.MONEY in allowed_updates:
        emitter.call_func("money_updated", Storage.money, false)
