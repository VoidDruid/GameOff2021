
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
    },
    {
        name: "G_NAME3",
        specialty_uid: RANDOM,
        cost_per_year: 70,
        price: 400,
        level: 2,
        overrides: {
            is_available: true,
            is_hired: true
        },
    },
];

{
    [key_n(character)]: character + {uid: key_n(character)},
    for character in characters
}
