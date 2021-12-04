local g = import 'general.lib.jsonnet';

local N_PREF = "GRANT_";

local n(obj, ind) = N_PREF + (
  if obj.specialty_uid == g.biology.name then "BIO"
  else if obj.specialty_uid == g.physics.name then "PHYS"
  else if obj.specialty_uid == g.math.name then "MATH"
  else if obj.specialty_uid == g.lingsoc.name then "LING"
  else if obj.specialty_uid == g.philosophy.name then "PHIL"
) + ind;

local auto_level(obj) = (
  if obj.amount < 2400 then 1
  else if obj.amount < 3400 then 2
  else 3
);

local auto_difficulty(obj) = std.clamp(
  std.floor(
    obj.amount *
    std.sqrt((std.log(obj.level) + 2/std.pow(obj.level, 2)) * obj.level)
    / 100,
  ),
  0, 95
);

local Grant(index, specialty) = {
  specialty_uid: specialty.name,
  name: n(self, index),
  difficulty: auto_difficulty(self),
  level: auto_level(self),
};

{
// Starting goals for different specialties
  bio_start: Grant(0, g.biology) {
    name: "GRANT_BIO_START",
    amount: 1800,
  },
  math_start: Grant(0, g.math) {
    name: "GRANT_MATH_START",
    amount: 1900,
  },
  phys_start: Grant(0, g.physics) {
    name: "GRANT_PHYS_START",
    amount: 2000,
  },
  philosophy_start: Grant(0, g.philosophy) {
    name: "GRANT_PHILOSOPHY_START",
    amount: 1900,
  },
  ling_start: Grant(0, g.lingsoc) {
    name: "GRANT_LING_START",
    amount: 1900,
  },
// MATH
  math2: Grant(2, g.math) {
    amount: 1950,
  },
  math3: Grant(3, g.math) {
    amount: 1700,
  },
  math4: Grant(4, g.math) {
    amount: 2800,
  },
  math5: Grant(5, g.math) {
    amount: 3000,
  },
  math6: Grant(6, g.math) {
    name:  n(self, 6),
    amount: 4500,
  },
// PHYS
  phys2: Grant(2, g.physics) {
    amount: 1900,
  },
  phys3: Grant(3, g.physics) {
    amount: 2000,
  },
  phys4: Grant(4, g.physics) {
    amount: 2750,
  },
  phys5: Grant(5, g.physics) {
    amount: 3100,
  },
  phys6: Grant(6, g.physics) {
    amount: 4300,
  },
// LING
  ling2: Grant(2, g.lingsoc) {
    amount: 1650,
  },
  ling3: Grant(3, g.lingsoc) {
    amount: 2200,
  },
  ling4: Grant(4, g.lingsoc) {
    amount: 2600,
  },
  ling5: Grant(5, g.lingsoc) {
    amount: 3350,
  },
  ling6: Grant(6, g.lingsoc) {
    amount: 4450,
  },
// PHIL
  phil2: Grant(2, g.philosophy) {
    amount: 1700,
  },
  phil3: Grant(3, g.philosophy) {
    amount: 1650,
  },
  phil4: Grant(4, g.philosophy) {
    amount: 3000,
  },
  phil5: Grant(5, g.philosophy) {
    amount: 2720,
  },
  phil6: Grant(6, g.philosophy) {
    amount: 5500,
  },
// BIO
  bio2: Grant(2, g.biology) {
    amount: 2000,
  },
  bio3: Grant(3, g.biology) {
    amount: 2040,
  },
  bio4: Grant(4, g.biology) {
    amount: 2900,
  },
  bio5: Grant(5, g.biology) {
    amount: 2700,
  },
  bio6: Grant(6, g.biology) {
    amount: 4200,
  },
}
