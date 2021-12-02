local g = import 'general.lib.jsonnet';

{
  bio_start: {
    name: "GRANT_BIO_START",
    amount: 150,
    specialty_uid: g.biology.name,
    difficulty: 10
  },
  math_start: {
    name: "GRANT_MATH_START",
    amount: 240,
    specialty_uid: g.math.name,
    level: 2,
    difficulty: 25
  },
  phys_start: {
    name: "GRANT_PHYS_START",
    amount: 180,
    specialty_uid: g.physics.name,
    difficulty: 15
  },
  philosophy_start: {
    name: "GRANT_PHILOSOPHY_START",
    amount: 170,
    specialty_uid: g.philosophy.name,
    difficulty: 13
  },
  ling_start: {
    name: "GRANT_LING_START",
    amount: 200,
    specialty_uid: g.lingsoc.name,
    difficulty: 20
  },
  bio2: {
    name: "GRANT_BIO2",
    amount: 200,
    specialty_uid: g.biology.name,
    difficulty: 20
  },
  phys2: {
    name: "GRANT_PHYS2",
    amount: 240,
    specialty_uid: g.physics.name,
    level: 2,
    difficulty: 25
  },
}
