
local g = import 'general.lib.jsonnet';

local key_n(obj) = if std.objectHas(obj, "uid")
    then obj.uid
    else std.md5(obj.name + obj.specialty_uid);

local RANDOM = "random";

local characters = [
    {
        name: "G_NAME1",
        specialty_uid: g.physics.name,
    },
    {
        name: "G_NAME2",
        specialty_uid: g.biology.name,
        overrides: {
            is_available: true
        },
        modifiers: [
            {
                property: "breakthrough_chance",
                value: 0.05,
            },
        ],
    },
    {
        name: "G_NAME3",
        specialty_uid: RANDOM,
        cost_per_year: 70,
        price: 400,
        level: 2,
        title: "phd",
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
];

{
    [key_n(character)]: character + {uid: key_n(character)},
    for character in characters
}
