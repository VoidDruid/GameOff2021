
local g = import 'general.lib.jsonnet';

local key_n(obj) = if std.objectHas(obj, "uid")
    then obj.uid
    else std.md5(obj.name + obj.specialty_uid);

local defaultKey(obj, field) = if !std.objectHas(obj, field) then field else null;

local preprocess(index, obj) = obj + {
    [defaultKey(obj, "name")]: "G_NAME" + (index + 1),
    [defaultKey(obj, "icon_uid")]: std.toString(index + 1),
};

local RANDOM = "random";

local calculate_cost(obj) = (
    if obj.level == 1 then 70
    else if obj.level == 2 then 100
    else if obj.level == 3 then 150
);
local calculate_price(obj) = (
    if obj.level == 1 then 250
    else if obj.level == 2 then 510
    else if obj.level == 3 then 730
);
local calculate_title(obj) = (
    null
);

local Character(specialty, additional_mods=[]) = {
    local this_character = self,
    specialty_uid: if specialty != RANDOM then specialty.name else specialty,
    level: 1,
    cost_per_year: calculate_price(self),
    price: calculate_cost(self),
    modifiers: [
        {
            property: "breakthrough_chance",
            value: std.floor(4 * (std.log(this_character.level) + 1.2)) / 100,
        },
    ] + additional_mods,
    title: calculate_title(self),
};

local characters = [
    // STARTING CHARACTER
    Character(RANDOM) {
        level: 2,
        overrides: {
            is_available: true,
            is_hired: true
        },
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.10,
            },
            {
                property: "yearly_cost",
                value: 0.05,
                positive: false
            },
        ],
    },
    Character(RANDOM),
    Character(RANDOM) {
        price: 150,
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.5,
            },
        ]
    },
    Character(RANDOM),
    Character(RANDOM) {
        modifiers: [
            {
                property: "yearly_cost",
                value: -0.05,
            },
        ],
    },
    Character(RANDOM),
    Character(RANDOM) {
        modifiers: [
            {
                property: "monthly_event_chance",
                value: 0.15,
            },
            {
                property: "yearly_cost",
                value: 0.05,
                positive: false
            },
        ]
    },
    Character(RANDOM),
    Character(RANDOM) {
        modifiers: [
            {
                property: "yearly_cost",
                value: -0.1,
            },
            {
                property: "breakthrough_chance",
                value: -0.03,
                positive: false
            },
        ],
    },
    Character(RANDOM),
    Character(RANDOM) {
        level: 2
    },
    Character(RANDOM, [{property: "yearly_cost", value: -0.1}],) {
        cost_per_year: 130,
        price: 600,
        level: 2
    },
    Character(RANDOM) {
        level: 2,
        modifiers: [
            {
                property: "yearly_cost",
                value: -0.05,
            },
            {
                property: "breakthrough_chance",
                value: 0.05,
            },
        ],
    },
    Character(RANDOM, [{property: "monthly_event_chance", value: -0.02, positive: false}],) {
        cost_per_year: 80,
        price: 400,
        level: 2
    },
    Character(RANDOM) {
        level: 2
    },
    Character(RANDOM) {
        level: 2,
        price: 650,
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.06,
            },
        ],
    },
    Character(RANDOM) {
        level: 2,
        price: 650,
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.06,
            },
        ],
    },
    Character(RANDOM) {
        level: 3,
    },
    Character(RANDOM) {
        level: 3,
        price: 800,
        title: "acad",
        cost_per_year: 250,
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.17,
            },
            {
                property: "yearly_cost",
                value: 0.05,
                positive: false
            },
        ],
    },
    Character(RANDOM, [{property: "monthly_event_chance", value: 0.33}],) {
        level: 3,
        cost_per_year: 400,
    },
    Character(RANDOM) {
        level: 3,
        price: 650,
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.06,
            },
        ],
    },
];

{
    [key_n(character)]: character + {uid: key_n(character)},
    for character in std.mapWithIndex(preprocess, characters)
}
