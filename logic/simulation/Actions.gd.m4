var Engine = null
var Storage = null
var T = null
var emitter = null

define(`COND_UPDATES')dnl
define(`ulist', `$1 if allowed_updates == null else utils.intersection($1, allowed_updates)')dnl
define(`conditional_update', `ifdef(`COND_UPDATES', `if allowed_updates == null or T.UpdateType.`'upcase($1)`' in allowed_updates:', `dnl')
`'ifdef(`COND_UPDATES', `            ',`')`'Engine.update_`'$1`'(ifelse($2,, $1, $2))
        `'ifdef(`COND_UPDATES', `    ',`')`'emitter.call_func("`'$1`'_updated", `'ifelse($2,, $1, $2)`'.uid)')dnl
define(`ACTION', `func `'$1`'(shift($*), update=true, `'ifdef(`COND_UPDATES', `',`_')`'allowed_updates=null):')dnl

ACTION(unassign_grant, faculty)
    if faculty.grant_uid == null:
        return
    var prev_grant = Storage.get_grant(faculty.grant_uid)
    Storage.grant_to_faculty[faculty.grant_uid] = null
    prev_grant.is_in_progress = false
    prev_grant.chance = 0
    faculty.grant_uid = null

    if update:
        conditional_update(faculty)
        conditional_update(grant, prev_grant)


ACTION(free_grant, grant)
    var prev_faculty_uid = Storage.grant_to_faculty[grant.uid]
    if prev_faculty_uid == null:
        return
    var prev_faculty = Storage.get_faculty(prev_faculty_uid)
    prev_faculty.grant_uid = null
    grant.chance = 0

    if update:
        conditional_update(grant)
        conditional_update(faculty, prev_faculty)


ACTION(remove_character_from_work, character)
    if character.faculty_uid == null:
        return

    var prev_faculty = Storage.get_faculty(character.faculty_uid)
    if prev_faculty.leader_uid == character.uid:
        prev_faculty.leader_uid = null
    else:
        prev_faculty.staff_uid_list.remove(prev_faculty.staff_uid_list.find(character.uid))

    character.faculty_uid = null

    if update:
        conditional_update(faculty, prev_faculty)
        conditional_update(character)

ACTION(assign_leader, faculty_uid, character_uid)
    var character = Storage.get_character(character_uid)
    character.is_hired = true
    remove_character_from_work(character, false)

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.leader_uid = character_uid

    if update:
        conditional_update(character)
        conditional_update(faculty)


ACTION(assign_grant, faculty_uid, grant_uid)
    var grant = Storage.get_grant(grant_uid)
    free_grant(grant, update, ulist([T.UpdateType.FACULTY]))
    grant.is_in_progress = true

    var faculty = Storage.get_faculty(faculty_uid)
    unassign_grant(faculty, update, ulist([T.UpdateType.GRANT]))
    faculty.grant_uid = grant_uid
    Storage.grant_to_faculty[grant_uid] = faculty_uid

    if update:
        conditional_update(grant)
        conditional_update(faculty)


ACTION(add_staff, faculty_uid, character_uid)
    var character = Storage.get_character(character_uid)
    character.is_hired = true
    remove_character_from_work(character, update, ulist([T.UpdateType.FACULTY]))

    var faculty = Storage.get_faculty(faculty_uid)
    character.faculty_uid = faculty_uid
    faculty.staff_uid_list.append(character_uid)

    if update:
        conditional_update(character)
        conditional_update(faculty)


ACTION(remove_staff, faculty_uid, character_uid)
    var character = Storage.get_character(character_uid)
    if character.faculty_uid != faculty_uid:
        utils.notify_error({
            "character_uid": character_uid,
            "faculty_uid": faculty_uid,
            "error": "Tried to remove staff from faculty, but character not working here!"
        })
        return
    remove_character_from_work(character, update, allowed_updates)


ACTION(buy_equipment, faculty_uid, equipment_uid)
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
        conditional_update(faculty)


ACTION(set_enrollee_count, faculty_uid, count)
    var faculty = Storage.get_faculty(faculty_uid)
    faculty.enrollee_count = count

    if update:
        conditional_update(faculty)


ACTION(hire_character, character_uid)
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
        conditional_update(character)

ACTION(fire_character, character_uid)
    var character = Storage.get_character(character_uid)
    if not character.is_hired:
        utils.notify_error({
            "character_uid": character_uid,
            "error": "Tried to fire character, that is not hired!"
        })
        return
    remove_character_from_work(character, update, ulist([T.UpdateType.FACULTY]))
    character.is_hired = false

    if update:
        conditional_update(character)


ACTION(take_grant, grant_uid)
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
        conditional_update(grant)
