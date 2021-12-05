local g = import 'general.lib.jsonnet';
local equipment = import 'equipment.jsonnet';

local uid_l(arr) = [obj.uid for obj in arr];

{
  biology: {
      name: "BIOLOGY_FACULTY_",
      default_cost: 70,
      default_enrollee_count: 30,
      default_breakthrough_chance: 30,
      specialty_uid: g.biology.name,
      equipment: uid_l([
            equipment.optimitzation,
            equipment.printer,
            equipment.microscope,
            equipment.projector,
            equipment.dna_sequencer
        ]),
    },
  physics: {
      name: "PHYSICS_FACULTY_",
      default_cost: 100,
      default_enrollee_count: 20,
      default_breakthrough_chance: 25,
      specialty_uid: g.physics.name,
      equipment: uid_l([
            equipment.optimitzation,
            equipment.printer,
            equipment.misc_equipment,
            equipment.computing_cluster,
            equipment.quantum_stuff
        ]),
    },
  philosophy: {
      name: "PHILOSOPHY_FACULTY_",
      default_cost: 50,
      default_enrollee_count: 7,
      default_breakthrough_chance: 35,
      specialty_uid: g.philosophy.name,
      equipment: uid_l([
            equipment.printer,
            equipment.library_catalog,
            equipment.projector,
            equipment.student_coworking
        ]),
    },
  math: {
      name: "MATH_FACULTY_",
      default_cost: 50,
      default_enrollee_count: 7,
      default_breakthrough_chance: 20,
      specialty_uid: g.philosophy.name,
      equipment: uid_l([
            equipment.printer,
            equipment.projector,
            equipment.computing_cluster,
            equipment.student_coworking
        ]),
    },
  ling_soc: {
      name: "LING_SOC_FACULTY_",
      default_cost: 60,
      default_enrollee_count: 10,
      default_breakthrough_chance: 30,
      specialty_uid: g.lingsoc.name,
      equipment: uid_l([
            equipment.optimitzation,
            equipment.printer,
            equipment.library_catalog,
            equipment.misc_equipment,
            equipment.projector,
        ]),
    },
}
