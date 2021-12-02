local g = import 'general.lib.jsonnet';
local equipment = import 'equipment.jsonnet';

{
    "biology": {
        "name": "BIOLOGY_FACULTY_",
        "default_cost": 70,
        "default_enrollee_count": 30,
        "default_breakthrough_chance": 15,
        "specialty_uid": g.biology.name,
        "equipment": [
            equipment.printer.uid,
            equipment.microscope.uid
        ],
    },
    "physics": {
        "name": "PHYSICS_FACULTY_",
        "default_cost": 100,
        "default_enrollee_count": 20,
        "default_breakthrough_chance": 25,
        "specialty_uid": g.physics.name,
        "equipment": [
            equipment.printer.uid,
            equipment.microscope.uid
        ],
    },
    "philosophy": {
        "name": "PHILOSOPHY_FACULTY_",
        "default_cost": 50,
        "default_enrollee_count": 7,
        "default_breakthrough_chance": 35,
        "specialty_uid": g.philosophy.name,
        "equipment": [
            equipment.printer.uid
        ],
    },
    "math": {
        "name": "MATH_FACULTY_",
        "default_cost": 50,
        "default_enrollee_count": 7,
        "default_breakthrough_chance": 35,
        "specialty_uid": g.philosophy.name,
        "equipment": [
            equipment.printer.uid
        ],
    },
    "ling_soc": {
        "name": "LING_SOC_FACULTY_",
        "default_cost": 60,
        "default_enrollee_count": 10,
        "default_breakthrough_chance": 25,
        "specialty_uid": g.lingsoc.name,
        "equipment": [
            equipment.printer.uid
        ],
    },
}
