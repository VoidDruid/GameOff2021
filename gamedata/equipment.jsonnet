# For each item (name, icon_id, price, modifiers) is a unique index
local build_uid(obj) = std.md5(obj.name + obj.icon_id + obj.price + obj.modifiers);

local Eq(index) = {
  uid: build_uid(self),
  icon_id: std.toString(index + 1),
};

{
  optimitzation: Eq(0) {
    name: "OPTIMIZATION_",
    price: 600,
    modifiers: [
      {
        value: -0.1,
        property: "yearly_cost"
      }
    ]
  },
  printer: Eq(1) {
    name: "PRINTER_",
    price: 600,
    modifiers: [
      {
        value: 0.03,
        property: "breakthrough_chance"
      }
    ]
  },
  library_catalog: Eq(2) {
    name: "LIBRARY_CATALOG",
    price: 700,
    modifiers: [
      {
        value: 0.04,
        property: "breakthrough_chance"
      }
    ]
  },
  projector: Eq(3) {
    name: "PROJECTOR_",
    price: 800,
    modifiers: [
      {
        value: 0.06,
        property: "breakthrough_chance"
      }
    ]
  },
  dna_sequencer: Eq(4) {
    name: "DNA_SEQUENCER",
    price: 120,
    modifiers: [
      {
        value: 0.1,
        property: "breakthrough_chance"
      }
    ]
  },
  microscope: Eq(5) {
    name: "MICROSCOPE_",
    price: 900,
    modifiers: [
      {
        value: 0.07,
        property: "breakthrough_chance"
      }
    ]
  },
  student_coworking: Eq(6) {
    name: "STUDENT_COWORKING",
    price: 750,
    modifiers: [
      {
        value: 0.01,
        property: "breakthrough_chance"
      },
      {
        value: 0.1,
        property: "enrollee_count"
      },
    ]
  },
  misc_equipment: Eq(7) {
    name: "MISC_EQUIPMENT",
    price: 500,
    modifiers: [
      {
        value: 0.03,
        property: "breakthrough_chance"
      },
      {
        value: 0.03,
        property: "enrollee_count"
      },
    ]
  },
  computing_cluster: Eq(8) {
    name: "COMPUTING_CLUSTER",
    price: 1200,
    modifiers: [
      {
        value: 0.1,
        property: "breakthrough_chance"
      }
    ]
  },
  quantum_stuff: Eq(9) {
    name: "QUANTUM_STUFF",
    price: 1600,
    modifiers: [
      {
        value: 0.15,
        property: "breakthrough_chance"
      }
    ]
  }
}
