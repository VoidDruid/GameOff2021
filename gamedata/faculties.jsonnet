local g = import 'general.lib.jsonnet';
local equipment = import 'equipment.jsonnet';

{
    "biology": {
        "name": "BIOLOGY_FACULTY_",
        "default_cost": 80,
        "default_enrollee_count": 20,
        "default_breakthrougn_chance": 20,
        "specialty_uid": g.biology.name,
        "equipment": [
            equipment.printer.uid
        ],
    },
}
