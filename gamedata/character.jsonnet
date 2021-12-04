
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

local characters = [
    {
        specialty_uid: g.physics.name,
    },
    {
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
    for character in std.mapWithIndex(preprocess, characters)
}
